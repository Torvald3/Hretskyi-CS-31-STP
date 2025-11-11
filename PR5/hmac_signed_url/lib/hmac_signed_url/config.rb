# frozen_string_literal: true


module HmacSignedUrl
  class Config
    attr_accessor :secret, :default_ttl, :algorithm, :sig_param, :exp_param, :http_method


    def initialize
      @secret       = ENV["HMAC_SECRET"] || "dev-secret-change-me"  # секретний ключ за замовчуванням
      @default_ttl  = 300                                           # TTL за замовчуванням (секунди)
      @algorithm    = "SHA256"                                      # алгоритм HMAC
      @sig_param    = "sig"                                         # ім’я параметра підпису в URL
      @exp_param    = "exp"                                         # ім’я параметра TTL/закінчення
      @http_method  = "GET"                                         # за замовчуванням включаємо метод GET у підпис
    end
  end


  class << self
    def config
      @config ||= Config.new # ініціалізація єдиного об’єкта конфігу
    end


    def configure
      yield(config) # зручний DSL: HmacSignedUrl.configure { |c| c.secret = "..." }
    end
  end
end