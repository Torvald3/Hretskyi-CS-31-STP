# hmac_signed_url


Простий гем для генерації й перевірки підписаних URL з TTL.


## Встановлення (локально з вихідних)
```bash
gem build hmac_signed_url.gemspec
gem install ./hmac_signed_url-0.1.0.gem


Використання

require "hmac_signed_url"


HmacSignedUrl.configure do |c|
c.secret = ENV.fetch("HMAC_SECRET") { "dev-secret-change-me" }
c.default_ttl = 300 # 5 хв за замовчуванням
end


signer = HmacSignedUrl::Signer.new


url = "https://example.com/download?file=report.pdf"


signed = signer.sign(url, ttl: 600) # дійсний 10 хвилин
# => "https://example.com/download?file=report.pdf&exp=1731250000&sig=..."


validator = HmacSignedUrl::Validator.new


validator.valid!(signed) # підніме помилку, якщо невалідний або протермінований
# або
validator.valid?(signed) # => true/false