import java.util.ArrayList;
import java.util.List;

public class Main {
    public static void main(String[] args) {
        Director director = new Director();

        CarBuilder carBuilder = new CarBuilder();
        director.constructSportsCar(carBuilder);
        Car car = carBuilder.getResult();
        System.out.println(car);

        CarManualBuilder manualBuilder = new CarManualBuilder();
        director.constructSportsCar(manualBuilder);
        Manual manual = manualBuilder.getResult();
        System.out.println(manual);
    }
}

/* ---------- Products (різні, без спільного предка) ---------- */
class Car {
    int seats;
    Engine engine;
    boolean tripComputer;
    boolean gps;

    @Override public String toString() {
        String e = (engine != null ? engine.getName() : "none");
        return "Car(seats=" + seats + ", engine=" + e +
                ", tripComputer=" + tripComputer + ", gps=" + gps + ")";
    }
}

class Manual {
    private final List<String> sections = new ArrayList<>();
    void add(String s) { sections.add(s); }
    @Override public String toString() {
        StringBuilder sb = new StringBuilder("Manual:\n");
        for (int i = 0; i < sections.size(); i++) {
            sb.append(i + 1).append(". ").append(sections.get(i)).append('\n');
        }
        return sb.toString();
    }
}

/* ---------- Support domain ---------- */
class Engine {
    private final String name;
    Engine(String name) { this.name = name; }
    String getName() { return name; }
}
class SportEngine extends Engine {
    SportEngine() { super("SportEngine"); }
}

/* ---------- Builder interface (спільні кроки процесу) ---------- */
interface Builder<T> {
    void reset();
    void setSeats(int seats);
    void setEngine(Engine engine);
    void setTripComputer(boolean on);
    void setGPS(boolean on);
    T getResult();
}

/* ---------- Concrete Builders (різна реалізація кроків) ---------- */
class CarBuilder implements Builder<Car> {
    private Car car = new Car();

    public void reset()                    { car = new Car(); }
    public void setSeats(int seats)        { car.seats = seats; }
    public void setEngine(Engine engine)   { car.engine = engine; }
    public void setTripComputer(boolean on){ car.tripComputer = on; }
    public void setGPS(boolean on)         { car.gps = on; }

    public Car getResult() {
        Car built = car;
        reset();
        return built;
    }
}

class CarManualBuilder implements Builder<Manual> {
    private Manual manual = new Manual();

    public void reset()                    { manual = new Manual(); }
    public void setSeats(int seats)        { manual.add("Сидіння: " + seats); }
    public void setEngine(Engine engine)   { manual.add("Двигун: " + engine.getName()); }
    public void setTripComputer(boolean on){ manual.add("Бортовий комп'ютер: " + (on ? "є" : "немає")); }
    public void setGPS(boolean on)         { manual.add("GPS: " + (on ? "увімкнено" : "відсутній")); }

    public Manual getResult() {
        Manual built = manual;
        reset();
        return built;
    }
}

/* ---------- Director (одна послідовність кроків) ---------- */
class Director {
    public <T> void constructSportsCar(Builder<T> builder) {
        builder.reset();
        builder.setSeats(2);
        builder.setEngine(new SportEngine());
        builder.setTripComputer(true);
        builder.setGPS(true);
    }

    // легко додати інший «рецепт», але процес лишається тим самим
    public <T> void constructCityCar(Builder<T> builder) {
        builder.reset();
        builder.setSeats(4);
        builder.setEngine(new Engine("CityEngine"));
        builder.setTripComputer(true);
        builder.setGPS(false);
    }
}
