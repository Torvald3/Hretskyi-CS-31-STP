# frozen_string_literal: true


require_relative "hmac_signed_url/version"   # підтягуємо константу VERSION
require_relative "hmac_signed_url/config"    # конфіг (secret, ttl, імена параметрів тощо)
require_relative "hmac_signed_url/errors"    # наші класи помилок (Expired, InvalidSignature…)
require_relative "hmac_signed_url/signer"    # генератор підписаних URL
require_relative "hmac_signed_url/validator" # перевірка підпису


module HmacSignedUrl
  # точка входу; нічого більше
end