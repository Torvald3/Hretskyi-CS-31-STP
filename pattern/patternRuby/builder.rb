# ---------- Products (різні, без спільного предка) ----------
class Car
  attr_accessor :seats, :engine, :trip_computer, :gps

  def initialize
    @seats = nil
    @engine = nil
    @trip_computer = false
    @gps = false
  end

  def to_s
    e = engine&.name || "none"
    "Car(seats=#{seats}, engine=#{e}, tripComputer=#{trip_computer}, gps=#{gps})"
  end
end

class Manual
  def initialize
    @sections = []
  end

  def add(text)
    @sections << text
  end

  def to_s
    lines = @sections.each_with_index.map { |s, i| "#{i + 1}. #{s}" }.join("\n")
    "Manual:\n#{lines}\n"
  end
end

# ---------- Support domain ----------
class Engine
  attr_reader :name
  def initialize(name) = @name = name
end

class SportEngine < Engine
  def initialize = super("SportEngine")
end

# ---------- Builder "інтерфейс" (контракт кроків) ----------
module Builder
  def reset;                 raise NotImplementedError end
  def set_seats(_seats);     raise NotImplementedError end
  def set_engine(_engine);   raise NotImplementedError end
  def set_trip_computer(_);  raise NotImplementedError end
  def set_gps(_);            raise NotImplementedError end
  def get_result;            raise NotImplementedError end
end

# ---------- Concrete Builders (різна реалізація кроків) ----------
class CarBuilder
  include Builder

  def initialize = reset

  def reset
    @car = Car.new
  end

  def set_seats(seats)          = @car.seats = seats
  def set_engine(engine)        = @car.engine = engine
  def set_trip_computer(on)     = @car.trip_computer = !!on
  def set_gps(on)               = @car.gps = !!on

  def get_result
    built = @car
    reset
    built
  end
end

class CarManualBuilder
  include Builder

  def initialize = reset

  def reset
    @manual = Manual.new
  end

  def set_seats(seats)          = @manual.add("Сидіння: #{seats}")
  def set_engine(engine)        = @manual.add("Двигун: #{engine.name}")
  def set_trip_computer(on)     = @manual.add("Бортовий комп'ютер: #{on ? 'є' : 'немає'}")
  def set_gps(on)               = @manual.add("GPS: #{on ? 'увімкнено' : 'відсутній'}")

  def get_result
    built = @manual
    reset
    built
  end
end

# ---------- Director (одна послідовність кроків) ----------
class Director
  def construct_sports_car(builder)
    builder.reset
    builder.set_seats(2)
    builder.set_engine(SportEngine.new)
    builder.set_trip_computer(true)
    builder.set_gps(true)
  end

  # легко додати інший «рецепт», процес лишається тим самим
  def construct_city_car(builder)
    builder.reset
    builder.set_seats(4)
    builder.set_engine(Engine.new("CityEngine"))
    builder.set_trip_computer(true)
    builder.set_gps(false)
  end
end

# ----------start----------

director = Director.new

car_builder = CarBuilder.new
director.construct_sports_car(car_builder)
car = car_builder.get_result
puts car
# => Car(seats=2, engine=SportEngine, tripComputer=true, gps=true)

manual_builder = CarManualBuilder.new
director.construct_sports_car(manual_builder)
manual = manual_builder.get_result
puts manual
# =>
# Manual:
# 1. Сидіння: 2
# 2. Двигун: SportEngine
# 3. Бортовий комп'ютер: є
# 4. GPS: увімкнено

# ruby .\STP\pattern\patternRuby\builder.rb