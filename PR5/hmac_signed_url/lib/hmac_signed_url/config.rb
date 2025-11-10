# frozen_string_literal: true


module HmacSignedUrl
  class Config
    attr_accessor :secret, :default_ttl, :algorithm, :sig_param, :exp_param, :http_method


    def initialize
      @secret = ENV["HMAC_SECRET"] || "dev-secret-change-me"
      @default_ttl = 300 # сек
      @algorithm = "SHA256"
      @sig_param = "sig"
      @exp_param = "exp"
      @http_method = "GET" # включаємо метод у підпис
    end
  end


  class << self
    def config
      @config ||= Config.new
    end


    def configure
      yield(config)
    end
  end
end