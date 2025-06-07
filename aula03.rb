class SalesReport
  include Enumerable

  def initialize(sales)
    @sales = sales
  end

  def each(&block)
    @sales.each(&block)
  end

  def total_by_category
    @sales.each_with_object(Hash.new(0)) do |sale, hash|
      hash[sale[:category]] += sale[:amount]
    end
  end

  def top_sales(n)
    @sales.max_by(n) { |sale| sale[:amount] }
  end

  def grouped_by_category
    @sales.group_by { |sale| sale[:category] }
  end

  def above_average_sales
    total = @sales.sum { |sale| sale[:amount] }
    average = total.to_f / @sales.size
    @sales.select { |sale| sale[:amount] > average }
  end
end

# Dados ampliados com mais vendas
sales = [
  { product: "Notebook", category: "Eletrônicos", amount: 3000 },
  { product: "Celular", category: "Eletrônicos", amount: 1500 },
  { product: "Cadeira", category: "Móveis", amount: 500 },
  { product: "Mesa", category: "Móveis", amount: 1200 },
  { product: "Headphone", category: "Eletrônicos", amount: 300 },
  { product: "Armário", category: "Móveis", amount: 800 },
  { product: "Monitor 4K", category: "Eletrônicos", amount: 2000 },
  { product: "Sofá", category: "Móveis", amount: 3500 },
  { product: "Tablet", category: "Eletrônicos", amount: 1200 },
  { product: "Estante", category: "Móveis", amount: 900 }
]

# Cria o relatório
report = SalesReport.new(sales)

# 1. Imprime todas as vendas usando o método each
puts "1. Todas as vendas:"
report.each { |sale| puts "#{sale[:product]} - #{sale[:category]} - R$#{sale[:amount]}" }
puts "\n" + "-"*80 + "\n\n"

# 2. Total por categoria
puts "2. Total de vendas por categoria:"
report.total_by_category.each do |category, total|
  puts "#{category}: R$#{total}"
end
puts "\n" + "-"*80 + "\n\n"

# 3. Top 3 vendas
puts "3. Top 3 vendas:"
report.top_sales(3).each_with_index do |sale, index|
  puts "#{index+1}. #{sale[:product]} - R$#{sale[:amount]}"
end
puts "\n" + "-"*80 + "\n\n"

# 4. Produtos agrupados por categoria
puts "4. Produtos agrupados por categoria:"
report.grouped_by_category.each do |category, products|
  puts "\n#{category}:"
  products.each { |p| puts "  • #{p[:product]} (R$#{p[:amount]})" }
end
puts "\n" + "-"*80 + "\n\n"

# 5. Vendas acima da média
total_geral = sales.sum { |s| s[:amount] }
media_geral = total_geral.to_f / sales.size
puts "5. Vendas acima da média geral (R$#{media_geral.round(2)}):"
report.above_average_sales.each do |sale|
  puts "#{sale[:product]} - R$#{sale[:amount]} (R$#{(sale[:amount] - media_geral).round(2)} acima)"
end