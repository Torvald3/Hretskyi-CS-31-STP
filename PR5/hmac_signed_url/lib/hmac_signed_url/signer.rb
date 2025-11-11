# frozen_string_literal: true

require "uri"                               # парсинг/збірка URL
require "openssl"                           # HMAC
require "base64"                            # кодування підпису в URL-safe рядок

module HmacSignedUrl
  class Signer
    def initialize(config = HmacSignedUrl.config)
      @config = config                      # тримаємо посилання на конфіг
    end

    # Повертає підписаний URL-рядок.
    # ttl: час життя (сек), якщо не задано — візьмемо default_ttl
    # expires_at: можна передати конкретний unix-time замість ttl
    # method: HTTP-метод, який включаємо в підпис (захист від підміни методу)
    def sign(url, ttl: nil, expires_at: nil, method: @config.http_method)
      uri = URI.parse(url)                  # парсимо рядок URL у об’єкт

      exp = if expires_at                   # обчислюємо момент закінчення
              expires_at.to_i
            else
              (Time.now.to_i + (ttl || @config.default_ttl).to_i)
            end

      query = URI.decode_www_form(String(uri.query))    # пари параметрів [[k,v], ...]
      # при повторному підписанні не має лишатися старих exp/sig
      query.reject! { |k, _| k == @config.sig_param || k == @config.exp_param }
      query << [@config.exp_param, exp.to_s]            # додаємо свій exp

      canonical_qs = canonical_query(query)             # стабільний відсортований query-рядок
      data = string_to_sign(method, uri.path, canonical_qs) # "METHOD\n/path\nk=v&..."
      signature = compute_signature(data)               # HMAC_SHA256 + Base64.urlsafe без '='

      # фінальний query = усі пари + sig
      query_with_sig = query + [[@config.sig_param, signature]]
      uri.query = URI.encode_www_form(query_with_sig)   # назад у рядок query
      uri.to_s                                        # результат: повний URL
    end

    private

    def canonical_query(pairs)
      # сортуємо спочатку за ключем, потім за значенням — стабільність порядку
      sorted = pairs.sort_by { |k, v| [k, v] }
      URI.encode_www_form(sorted)                     # кодуємо у стандартний query-рядок
    end

    def string_to_sign(method, path, canonical_qs)
      [method.to_s.upcase, path, canonical_qs].join("\n")  # формуємо канонічний рядок підпису
    end

    def compute_signature(data)
      raw = OpenSSL::HMAC.digest(@config.algorithm, @config.secret, data) # байти HMAC
      Base64.urlsafe_encode64(raw).delete("=")                             # URL-safe base64 без паддінгу
    end
  end
end


#цей клас використовують і тести (для генерації підписаних URL), і демо-сервер (щоб видати клієнту робоче посилання).