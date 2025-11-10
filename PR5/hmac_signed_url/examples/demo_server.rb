# frozen_string_literal: true
# Демонстраційний міні-сервер на WEBrick (без зовнішніх залежностей)
# Запуск: ruby examples/demo_server.rb


require "webrick"
require_relative "../lib/hmac_signed_url"


HmacSignedUrl.configure do |c|
  c.secret = ENV.fetch("HMAC_SECRET", "dev-secret-change-me")
  c.default_ttl = 120 # 2 хвилини
end


signer = HmacSignedUrl::Signer.new
validator = HmacSignedUrl::Validator.new


server = WEBrick::HTTPServer.new(Port: 9292)


# Головна сторінка: показує підписаний лінк
server.mount_proc "/" do |req, res|
  base = "http://#{req.host}:#{req.port}/download?file=report.pdf"
  signed = signer.sign(base, ttl: 60) # дійсний 60 секунд
  res.body = <<~HTML
    <h1>HMAC Signed URL demo</h1>
    <p>Згенеровано підписане посилання (дійсне 60 с):</p>
    <p><a href="#{signed}">#{signed}</a></p>
    <p>Спробуй відкрити його. Після 60 с або при зміні будь-якого параметра — отримаєш 403.</p>
  HTML
end


# Захищений ресурс
server.mount_proc "/download" do |req, res|
  full_url = "http://#{req.host}:#{req.port}#{req.request_uri}"
  begin
    validator.valid!(full_url, method: req.request_method)
    filename = req.query["file"] || "unknown"
    res.body = "OK! Ви маєте доступ до #{filename}"
  rescue => e
    res.status = 403
    res.body = "403 Forbidden — #{e.class}: #{e.message}"
  end
end


trap("INT") { server.shutdown }
server.start