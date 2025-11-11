# hmac_signed_url


Простий гем для генерації й перевірки підписаних URL з TTL.

## Встановлення (локально з вихідних)
```bash
gem build hmac_signed_url.gemspec
gem install ./hmac_signed_url-0.1.0.gem

## Весь шлях
# 0) Перевірити C:\Users\PC\.local\share\gem\ruby\3.4.0\gems чи є hmac_signed_url-0.1.0, 
# для демонстрації видали(можеш спробувати крок 4 як доказ наявності), 
# бо require "hmac_signed_url" – підключає твій встановлений гем
# а також видали Gemfile.lock і hmac_signed_url-0.1.0.gem

# 1) Встановити залежності для розробки
bundle install

# 2) Прогнати тести
bundle exec rspec

# 3) Зібрати гем
gem build hmac_signed_url.gemspec
# Встановити локально зібраний гем
gem install ./hmac_signed_url-0.1.0.gem

# 4) Запустити демо-сервер
ruby examples/demo_server.rb
# Перейти у браузері на http://localhost:9292

## Використання(Альтернатива)
1)У терміналі VS Code (або PowerShell) відкрити проєкт і набрати: 
irb

1.1) З’явиться запрошення типу:(Interactive Ruby)
irb(main):001:0>

2) Далі в цьому інтерактивному режимі команди:

require "hmac_signed_url"

signer = HmacSignedUrl::Signer.new

puts signer.sign("https://ex.com/download?file=a.txt", ttl: 30)


3) У відповідь IRB виведе приблизно таке:

https://ex.com/download?file=a.txt&exp=1731355323&sig=F1zQ0VkR8K6r...

Це означає, що гем підключився, підпис згенерувався, усе працює.

4) Вийти з IRB:

exit
