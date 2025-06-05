class Vector2
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def *(other)
    case other
    when Numeric
      Vector2.new(x * other, y * other)
    when Vector2
      x * other.x + y * other.y
    else
      raise TypeError, "Tipo não suportado: #{other.class}"
    end
  end

  def coerce(other)
    if other.is_a?(Numeric)
      [self, other]
    else
      raise TypeError, "Tipo não suportado: #{other.class}"
    end
  end

  def to_s
    "(#{x}, #{y})"
  end
end

puts "\n=== TESTES VECTOR2 ==="
v = Vector2.new(3, 4)

puts "v * 2    = #{v * 2}"
puts "v * 2.5  = #{v * 2.5}"
puts "v * v    = #{v * v}"
puts "2 * v    = #{2 * v}"
puts "2.5 * v  = #{2.5 * v}"

class HtmlBuilder
  def initialize(&block)
    @html = ""
    instance_eval(&block) if block_given?
  end

  def div(content = nil, &block)
    if block_given?
      @html << "<div>"
      instance_eval(&block)
      @html << "</div>"
    else
      @html << "<div>#{content}</div>"
    end
  end

  def span(content = nil, &block)
    if block_given?
      @html << "<span>"
      instance_eval(&block)
      @html << "</span>"
    else
      @html << "<span>#{content}</span>"
    end
  end

  def result
    @html
  end
end

puts "\n=== TESTE HTML BUILDER CONFORME ENUNCIADO ==="
builder = HtmlBuilder.new do
  div do
    div "Conteúdo em div"
    span "Nota em div"
  end
  span "Nota de rodapé"
end

puts builder.result
