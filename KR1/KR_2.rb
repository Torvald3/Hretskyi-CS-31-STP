# 2) csv_stream.rb
# Стрімінговий CSV-парсер. Типи задаються в заголовках: name[:type]
# Підтримувані кастери: int, decimal, time.

require "csv"
require "bigdecimal" #щоб не було оцього "0.000000004"
require "time"

DEFAULT_CASTERS = {
  int:     ->(s) { s.nil? || s.empty? ? nil : s.to_i },
  decimal: ->(s) { s.nil? || s.empty? ? nil : BigDecimal(s) },
  time:    ->(s) { s.nil? || s.empty? ? nil : Time.parse(s) },
  nil =>   ->(s) { s }
}

def stream_csv(path, casters: DEFAULT_CASTERS)
  headers = nil
  columns = nil

  CSV.foreach(path) do |row|
    if headers.nil?
      headers = row
      columns = headers.map do |h|                          # Будуємо "схему" перетворень для кожної колонки //ТУДУ: Правильний хедер не забуудь зробити
        name, type = h.to_s.split(":", 2)                   # Розбиваємо "імʼя:тип" на частини
        caster = casters.fetch(type&.to_sym, casters[nil])  # Беремо потрібний перетворювач
        [name.to_sym, caster]                               # Зберігаємо як [імʼя_символом, функція]
      end
      next
    end

    out = {}
    columns.each_with_index do |(name, caster), i|
      out[name] = caster.call(row[i])
    end

    yield out
  end
end

# Виклик:
stream_csv("data.csv") do |row|
  p row
end
