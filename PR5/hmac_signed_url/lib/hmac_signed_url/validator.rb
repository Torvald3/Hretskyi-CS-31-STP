# frozen_string_literal: true


require "uri"
require "openssl"
require "base64"


module HmacSignedUrl
  class Validator
    def initialize(config = HmacSignedUrl.config)
      @config = config
    end


    # valid? -> true/false
    def valid?(url, method: @config.http_method, now: Time.now.to_i)
      validate(url, method: method, now: now)
      true
    rescue HmacSignedUrl::Error
      false
    end


    # valid! -> піднімає помилки типу MissingExpiry / Expired / InvalidSignature
    def valid!(url, method: @config.http_method, now: Time.now.to_i)
      validate(url, method: method, now: now)
      true
    end


    private


    def validate(url, method:, now:)
      uri = URI.parse(url)
      pairs = URI.decode_www_form(String(uri.query))
      q_hash = pairs.to_h


      exp_str = q_hash[@config.exp_param]
      raise MissingExpiry, "missing #{@config.exp_param}" if exp_str.nil? || exp_str.empty?


      exp = exp_str.to_i
      raise Expired, "expired at #{exp}" if now > exp


      sig = q_hash[@config.sig_param]
      raise InvalidSignature, "missing signature" if sig.nil? || sig.empty?


      # При перевірці sig **не** повинна бути у canonical query
      pairs.reject! { |k, _| k == @config.sig_param }
      canonical_qs = canonical_query(pairs)
      data = string_to_sign(method, uri.path, canonical_qs)
      expected = compute_signature(data)


      # захист від таймінг-атаки — "secure compare"
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


    # Постійне порівняння довжин/байтів
    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize
      l = a.unpack("C*")
      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end
  end
end