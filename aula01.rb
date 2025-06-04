require 'set'

class Settings
  def initialize
    @configs = {}
    @aliases = {}
    @readonly = Set.new
  end

def add(name, value, aliases: nil, readonly: false)
  @configs[name] = value
  @readonly << name if readonly

  if aliases
    Array(aliases).each do |a|
      @aliases[a] = name
    end
  end

  define_singleton_method(name) do
    @configs[name]
  end

  @aliases.each do |alias_name, main_name|
    next if main_name != name
    define_singleton_method(alias_name) do
      @configs[main_name]
    end
  end

  unless readonly
    define_singleton_method("#{name}=") do |new_value|
      @configs[name] = new_value
    end
  end
end

  def method_missing(name, *args)
    if name.to_s.end_with?('=')
      attr_name = name.to_s.chop.to_sym
      handle_setter(attr_name, args.first)
    else
      handle_getter(name)
    end
  end

  def respond_to_missing?(name, include_private = false)
    name_str = name.to_s
    if name_str.end_with?('=')
      attr_name = name_str.chop.to_sym
      valid_setter?(attr_name)
    else
      valid_getter?(name)
    end
  end

  def all
    @configs.dup
  end

  private

  def valid_getter?(name)
    @configs.key?(name) || @aliases.key?(name)
  end

  def valid_setter?(name)
    @configs.key?(name) && !@readonly.include?(name)
  end

  def handle_getter(name)
    if @aliases.key?(name)
      @configs[@aliases[name]]
    elsif @configs.key?(name)
      @configs[name]
    else
      "Configuração '#{name}' não existe."
    end
  end

  def handle_setter(name, value)
    if @readonly.include?(name)
      raise "Erro: configuração '#{name}' é somente leitura"
    elsif @configs.key?(name)
      @configs[name] = value
    else
      super
    end
  end
end

# ------------------------------------------
# Demonstração de uso com impressões
# ------------------------------------------

puts "Criando configurações..."
settings = Settings.new
settings.add(:timeout, 30, aliases: :espera)
settings.add(:mode, :production)
settings.add(:api_key, "SECRET-123", readonly: true)
settings.add(:max_connections, 5, aliases: [:conexoes, :connections])

puts "\nAcessando valores:"
puts "Timeout: #{settings.timeout}"
puts "Espera (alias): #{settings.espera}"
puts "Modo: #{settings.mode}"
puts "API Key: #{settings.api_key}"
puts "Conexões: #{settings.conexoes}"
puts "Connections: #{settings.connections}"
puts "Configuração inexistente: #{settings.retry}"

puts "\nAlterando valores:"
settings.timeout = 60
puts "Novo timeout: #{settings.timeout}"
puts "Espera (atualizado): #{settings.espera}"

begin
  puts "\nTentando alterar chave API (readonly):"
  settings.api_key = "HACKED"
rescue => e
  puts "ERRO: #{e.message}"
end

puts "\nListando todas as configurações:"
puts settings.all.inspect

puts "\nTestando setters dinâmicos:"
settings.mode = :development
puts "Novo modo: #{settings.mode}"

puts "\nTestando respond_to?:"
puts "Responde a timeout? #{settings.respond_to?(:timeout)}"
puts "Responde a espera? #{settings.respond_to?(:espera)}"
puts "Responde a api_key=? #{settings.respond_to?(:api_key=)}"
puts "Responde a retry? #{settings.respond_to?(:retry)}"
