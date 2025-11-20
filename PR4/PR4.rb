# створити консольний додаток RecipeCraft (рецепти, комора та конвертація одиниць)
# Зробити класи або модулi:

# Ingredient(name, unit ∈ :g,:kg,:ml,:l,:pcs, calories_per_unit за базову од.)
# Recipe(name, steps[], items[{ingredient, qty, unit}]), метод need - все в базових (:g/:ml/:pcs)
# Pantry.add(name, qty, unit), available_for(name) - у базових
# UnitConverter: kg-g ×1000, l↔ml ×1000, pcs-pcs ×1; маса-об’єм - заборонено
# Planner.plan(recipes, pantry, price_list) -
# need/have/deficit по кожному інгредієнту + total_calories + total_cost (ціни за базову од.)

# Перевірка (demo.rb):
# Комора: борошно 1 кг; молоко 0.5 л; яйця 6 шт; паста 300 г; сир 150 г
# Ціни (за базу): борошно г=0.02; молоко мл=0.015; яйце шт=6.0; паста г=0.03; соус мл=0.025; сир г=0.08
# Калорії/база: яйце 72/шт; молоко 0.06/мл; борошно 3.64/г; паста 3.5/г; соус 0.2/мл; сир 4.0/г
# Рецепти: «Омлет» (яйця 3 шт, молоко 100 мл, борошно 20 г); «Паста» (паста 200 г, соус 150 мл, сир 50 г)
# Вивести рядки «потрібно / є / дефіцит» + total_calories, total_cost
# ----------------------------------------------------------------------------------------------------------------------------------------

# --- UnitConverter -----------------------------------------------------------
module UnitConverter
  MASS   = [:g, :kg]
  VOLUME = [:ml, :l]
  COUNT  = [:pcs]

  BASE_OF = {
    g: :g, kg: :g,
    ml: :ml, l: :ml,
    pcs: :pcs
  }

  FACTOR_TO_BASE = {
    g: 1.0, kg: 1000.0,
    ml: 1.0, l: 1000.0,
    pcs: 1.0
  }

  def self.same_dimension?(u1, u2) #static
    [MASS, VOLUME, COUNT].any? { |set| set.include?(u1) && set.include?(u2) }
  end

  def self.base_of(unit) #static
    BASE_OF[unit] or raise ArgumentError, "Невідома одиниця: #{unit}"
  end

  def self.to_base(qty, unit) #static
    base = base_of(unit)
    [qty * FACTOR_TO_BASE[unit], base]
  end
end

# --- Ingredient --------------------------------------------------------------
class Ingredient
  attr_reader :name, :unit, :calories_per_unit
  # unit — БАЗОВА (:g, :ml, :pcs). calories_per_unit — за базову од.
  def initialize(name:, unit:, calories_per_unit:)
    unless [:g, :ml, :pcs].include?(unit)
      raise ArgumentError, "Інгредієнт '#{name}' має бути у базовій од. (:g, :ml або :pcs)"
    end
    @name = name
    @unit = unit
    @calories_per_unit = calories_per_unit.to_f
  end
end

# --- Recipe ------------------------------------------------------------------
class Recipe
  Item = Struct.new(:ingredient, :qty, :unit, keyword_init: true)

  attr_reader :name, :steps, :items
  def initialize(name:, steps: [], items: [])
    @name = name
    @steps = steps
    @items = items # масив Recipe::Item
  end

  # Повертає Hash{name => {qty: Float, unit: base_sym}}
  # усе у базових од. (:g / :ml / :pcs)
  def need
    need = Hash.new { |h,k| h[k] = { qty: 0.0, unit: nil } }
    @items.each do |it|
      qty_base, base = UnitConverter.to_base(it.qty.to_f, it.unit)
      name = it.ingredient.name
      need[name][:qty]  += qty_base
      need[name][:unit]  = base
    end
    need
  end
end

# --- Pantry ------------------------------------------------------------------
class Pantry
  # Зберігаємо у базових од.
  def initialize
    @store = Hash.new { |h,k| h[k] = { qty: 0.0, unit: nil } }
  end

  def add(name, qty, unit)
    qty_base, base = UnitConverter.to_base(qty.to_f, unit)
    @store[name][:qty]  += qty_base
    @store[name][:unit]  = base
  end

  # Скільки доступно (у базових)
  # -> {qty: Float, unit: base_sym} або {qty:0, unit:nil} якщо немає
  def available_for(name)
    @store[name] || { qty: 0.0, unit: nil }
  end
end

# --- Planner -----------------------------------------------------------------
class Planner
  # recipes: [Recipe], pantry: Pantry,
  # price_list: { "назва" => ціна_за_базову_од. }
  # Повертає:
  # {
  #   per_item: { "назва" => {need:, have:, deficit:, unit:} },
  #   total_calories: Float,
  #   total_cost: Float
  # }
  def self.plan(recipes, pantry, price_list) #static
    # 1) сума потреб
    need_sum = Hash.new { |h,k| h[k] = { qty: 0.0, unit: nil } }
    recipes.each do |r|
      r.need.each do |name, data|
        need_sum[name][:qty]  += data[:qty]
        need_sum[name][:unit]  = data[:unit]
      end
    end

    # 2) по кожному інгредієнту: have/deficit
    per_item = {}
    need_sum.each do |name, data|
      have = pantry.available_for(name)[:qty] || 0.0
      need = data[:qty]
      deficit = [need - have, 0.0].max
      per_item[name] = { need: need, have: have, deficit: deficit, unit: data[:unit] }
    end

    # 3) калорії (по потрібному, а не по дефіциту)
    # потрібні інгредієнти => шукаємо їх об’єкти інгредієнтів через карту нижче
    # (передамо окремо)
    total_calories = yield(:calories, per_item) if block_given?
    total_calories ||= 0.0

    # 4) вартість — лише те, чого бракує
    total_cost = 0.0
    per_item.each do |name, row|
      price = price_list[name] || 0.0
      item_cost = row[:deficit] * price
      total_cost += item_cost
    end
    
    { per_item: per_item, total_calories: total_calories, total_cost: total_cost }
  end
end

# ================== Д Е М О ==================================================
# Інгредієнти (калорії за базову одиницю)
ING = {
  "яйце"    => Ingredient.new(name: "яйце",    unit: :pcs, calories_per_unit: 72.0),
  "молоко"  => Ingredient.new(name: "молоко",  unit: :ml,  calories_per_unit: 0.06),
  "борошно" => Ingredient.new(name: "борошно", unit: :g,   calories_per_unit: 3.64),
  "паста"   => Ingredient.new(name: "паста",   unit: :g,   calories_per_unit: 3.5),
  "соус"    => Ingredient.new(name: "соус",    unit: :ml,  calories_per_unit: 0.2),
  "сир"     => Ingredient.new(name: "сир",     unit: :g,   calories_per_unit: 4.0)
}

# Рецепти:
omlet = Recipe.new(
  name: "Омлет",
  items: [
    Recipe::Item.new(ingredient: ING["яйце"],   qty: 3,   unit: :pcs),
    Recipe::Item.new(ingredient: ING["молоко"], qty: 100, unit: :ml),
    Recipe::Item.new(ingredient: ING["борошно"],qty: 20,  unit: :g)
  ]
)

pasta = Recipe.new(
  name: "Паста",
  items: [
    Recipe::Item.new(ingredient: ING["паста"], qty: 200, unit: :g),
    Recipe::Item.new(ingredient: ING["соус"],  qty: 150, unit: :ml),
    Recipe::Item.new(ingredient: ING["сир"],   qty: 50,  unit: :g)
  ]
)

recipes = [omlet, pasta]

# Комора:
pantry = Pantry.new
pantry.add("борошно", 1,   :kg)
pantry.add("молоко",  0.5, :l)
pantry.add("яйце",    6,   :pcs)
pantry.add("паста",   300, :g)
pantry.add("сир",     150, :g)

# Ціни (за базу):
prices = {
  "борошно" => 0.02,   # грн/г (умовно)
  "молоко"  => 0.015,  # грн/мл
  "яйце"    => 6.0,    # грн/шт
  "паста"   => 0.03,   # грн/г
  "соус"    => 0.025,  # грн/мл
  "сир"     => 0.08    # грн/г
}

# Планування:
result = Planner.plan(recipes, pantry, prices) do |what, per_item| #Planner рахує «потрібно/є/дефіцит» і вартість, але не знає, де взяти калорійність. Якщо потрібні калорії — даєш блок, у якому знаєш, як знайти Ingredient та його calories_per_unit. Якщо калорії не потрібні — не даєш блок, і Planner просто ставить 0.0, не падаючи з помилкою.
  if what == :calories
    per_item.sum do |name, row|
      ing = ING[name]
      ing.calories_per_unit * row[:need] # калорії за потрібною кількістю
    end
  end
end

# Вивід:
puts "План приготування: #{recipes.map(&:name).join(' + ')}"
puts "-" * 60
result[:per_item].each do |name, row|
  unit = row[:unit]
  puts "#{name}: потрібно #{'%.2f' % row[:need]} #{unit} / " \
       "є #{'%.2f' % row[:have]} #{unit} / " \
       "дефіцит #{'%.2f' % row[:deficit]} #{unit}"
end
puts "-" * 60
puts "total_calories: %.2f ккал" % result[:total_calories]
puts "total_cost:     %.2f" % result[:total_cost]

# ruby .\PR4\PR4.rb