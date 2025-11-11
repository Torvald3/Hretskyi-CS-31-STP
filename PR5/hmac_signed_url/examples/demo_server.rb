# frozen_string_literal: true
# Демонстраційний міні-сервер на WEBrick (без зовнішніх залежностей)
# Запуск: ruby examples/demo_server.rb


require "webrick"                               # міні-вебсервер без зайвих залежностей
require "hmac_signed_url"                       # підключаємо гем локально

HmacSignedUrl.configure do |c|
  c.secret = ENV.fetch("HMAC_SECRET", "dev-secret-change-me")
  c.default_ttl = 120
end

signer = HmacSignedUrl::Signer.new              # створюємо генератор
validator = HmacSignedUrl::Validator.new        # і валідатор

server = WEBrick::HTTPServer.new(Port: 9292)    # стартуємо сервер

# server.mount_proc — це спосіб сказати WEBrick’у: “коли приходить HTTP-запит на цей шлях, виконай оцей блок коду”.
server.mount_proc "/" do |req, res|             # головна: показати підписане посилання
  base = "http://#{req.host}:#{req.port}/download?file=report.pdf"
  signed = signer.sign(base, ttl: 60)
  res.body = <<~HTML
    <h1>HMAC Signed URL demo</h1>
    <p><a href="#{signed}">#{signed}</a></p>
  HTML
end

server.mount_proc "/download" do |req, res|     # захищений маршрут
  full_url = "http://#{req.host}:#{req.port}#{req.path}?#{req.query_string}" # це і є те, що ми перевіряємо
  begin
    validator.valid!(full_url, method: req.request_method) # перевірка: exp + sig
    res.body = "OK! U have an access to file #{req.query["file"]}"
  rescue => e
    res.status = 403
    res.body = "403 Forbidden — #{e.class}: #{e.message}"
  end
end

trap("INT") { server.shutdown }                 # коректне завершення по Ctrl+C
server.start


#http://localhost:9292/