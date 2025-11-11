# frozen_string_literal: true

require "uri"
require "openssl"
require "base64"

module HmacSignedUrl
  class Validator
    def initialize(config = HmacSignedUrl.config)
      @config = config
    end

    # valid? — м’яка перевірка: true/false
    def valid?(url, method: @config.http_method, now: Time.now.to_i)
      validate(url, method: method, now: now)   # пробуємо валідувати
      true                                      # якщо без помилок — валідний
    rescue HmacSignedUrl::Error                 # наші помилки
      false
    end

    # valid! — жорстка перевірка: кидає конкретну помилку
    def valid!(url, method: @config.http_method, now: Time.now.to_i)
      validate(url, method: method, now: now)
      true
    end

    private

    def validate(url, method:, now:)
      uri = URI.parse(url)
      pairs = URI.decode_www_form(String(uri.query))   # список пар [[k,v], ...]
      q_hash = pairs.to_h                              # зручно витягнути exp/sig

      exp_str = q_hash[@config.exp_param]              # дістаємо exp
      raise MissingExpiry, "missing #{@config.exp_param}" if exp_str.nil? || exp_str.empty?

      exp = exp_str.to_i
      raise Expired, "expired at #{exp}" if now > exp  # TTL минув — стоп

      sig = q_hash[@config.sig_param]                  # дістаємо sig
      raise InvalidSignature, "missing signature" if sig.nil? || sig.empty?

      # дуже важливо: при формуванні рядка-для-підпису ми НЕ включаємо sig
      pairs.reject! { |k, _| k == @config.sig_param }
      canonical_qs = canonical_query(pairs)
      data = string_to_sign(method, uri.path, canonical_qs)
      expected = compute_signature(data)               # «правильний» підпис

      # Порівняння у сталий час (щоб таймінг не «здав» позицію різниці)
      unless secure_compare(sig, expected)
        raise InvalidSignature, "bad signature"
      end
    end

    def canonical_query(pairs)
      sorted = pairs.sort_by { |k, v| [k, v] }
      URI.encode_www_form(sorted)
    end

    def string_to_sign(method, path, canonical_qs)
      [method.to_s.upcase, path, canonical_qs].join("\n")
    end

    def compute_signature(data)
      raw = OpenSSL::HMAC.digest(@config.algorithm, @config.secret, data)
      Base64.urlsafe_encode64(raw).delete("=")
    end

    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize     # різний розмір — одразу false
      l = a.unpack("C*")                               # перетворюємо на масив байтів
      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }     # XOR по кожному байту
      res == 0                                         # 0 => усі байти збіглися
    end
  end
end


#викликається у демо-сервері на маршруті /download перед тим, як дати доступ.