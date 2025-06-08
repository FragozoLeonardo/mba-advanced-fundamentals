require 'thread'

class PriorityQueue
  PRIORITIES = [:high, :medium, :low, :default].freeze

  def initialize
    @queues = Hash.new { |h, k| h[k] = Queue.new }
    @mutex = Mutex.new
  end

  def add(priority, task)
    @mutex.synchronize do
      priority = :default unless PRIORITIES.include?(priority)
      @queues[priority] << task
    end
  end

  def next
    @mutex.synchronize do
      PRIORITIES.each do |priority|
        queue = @queues[priority]
        return queue.deq(true) unless queue.empty?
      end
      nil
    end
  end
end

class DynamicThreadPool
  def initialize(initial_threads: 2, max_threads: 10)
    @max_threads = max_threads
    @queue = PriorityQueue.new
    @mutex = Mutex.new
    @condition = ConditionVariable.new
    @shutdown = false
    @threads = []
    @busy_threads = 0

    initial_threads.times { spawn_thread }
  end

  def schedule(priority = :default, &block)
    @mutex.synchronize do
      return if @shutdown
      @queue.add(priority, block)
      
      if @busy_threads == @threads.size && @threads.size < @max_threads
        spawn_thread
      end
      
      @condition.signal
    end
  end

  def shutdown
    @mutex.synchronize do
      @shutdown = true
      @condition.broadcast
    end
    
    @threads.each(&:join)
  end

  private

  def spawn_thread
    thread = Thread.new do
      loop do
        task = nil
        should_exit = false

        @mutex.synchronize do
          while (task = @queue.next).nil?
            if @shutdown
              should_exit = true
              break
            end
            @condition.wait(@mutex)
          end
        end

        break if should_exit

        @mutex.synchronize do
          @busy_threads += 1
        end

        begin
          task.call
        ensure
          @mutex.synchronize do
            @busy_threads -= 1
            @condition.signal
          end
        end
      end
    end
    
    @threads << thread
  end
end

# Exemplo de uso
pool = DynamicThreadPool.new(initial_threads: 2, max_threads: 3)

10.times do |i|
  pool.schedule(:default) do 
    sleep rand(0.1..0.3)
    puts "Tarefa padrão #{i} concluída"
  end
end

5.times do |i|
  pool.schedule(:high) do 
    sleep rand(0.1..0.2)
    puts "TAREFA PRIORITÁRIA #{i} concluída!"
  end
end

sleep 2 # Garante tempo para processamento
pool.shutdown