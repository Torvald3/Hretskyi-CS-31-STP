# frozen_string_literal: true


require "uri"
require "openssl"
require "base64"


module HmacSignedUrl
  class Signer
    def initialize(config = HmacSignedUrl.config)
      @config = config
    end


    # Повертає ПІДПИСАНИЙ URL (рядок)
    # ttl: у секундах; якщо не задано — візьмемо config.default_ttl
    def sign(url, ttl: nil, expires_at: nil, method: @config.http_method)
      uri = URI.parse(url)


      exp = if expires_at
              expires_at.to_i
              else
                (Time.now.to_i + (ttl || @config.default_ttl).to_i)
              end


      query = URI.decode_www_form(String(uri.query))
      # Видалимо попередні sig/exp якщо вони є
      query.reject! { |k, _| k == @config.sig_param || k == @config.exp_param }
      query << [@config.exp_param, exp.to_s]


      canonical_qs = canonical_query(query)
      data = string_to_sign(method, uri.path, canonical_qs)
      signature = compute_signature(data)


      # збираємо фінальний URL
      query_with_sig = query + [[@config.sig_param, signature]]
      uri.query = URI.encode_www_form(query_with_sig)
      uri.to_s
    end


    # те ж саме, але повертає parts: { exp:, sig:, data:, canonical_qs: }
    def sign_debug(url, **kwargs)
      uri = URI.parse(url)
      signed = sign(url, **kwargs)
      s_uri = URI.parse(signed)
      q = URI.decode_www_form(String(s_uri.query)).to_h
      {
        signed_url: signed,
        exp: q[@config.exp_param],
        sig: q[@config.sig_param],
        canonical_qs: canonical_query((URI.decode_www_form(String(s_uri.query)) - [[@config.sig_param, q[@config.sig_param]]])),
        string_to_sign: string_to_sign(@config.http_method, uri.path, canonical_query((URI.decode_www_form(String(s_uri.query)) - [[@config.sig_param, q[@config.sig_param]]])))
      }
    end


    private


    def canonical_query(pairs)
      # pairs: [[k,v], ...] без sig; сортуємо за k, потім v
      sorted = pairs.sort_by { |k, v| [k, v] }
      URI.encode_www_form(sorted) # стабільний порядок і кодування
    end


    def string_to_sign(method, path, canonical_qs)
      [method.to_s.upcase, path, canonical_qs].join("\n")
    end


    def compute_signature(data)
      raw = OpenSSL::HMAC.digest(@config.algorithm, @config.secret, data)
      Base64.urlsafe_encode64(raw).delete("=")
    end
  end
end