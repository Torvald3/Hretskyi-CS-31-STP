# frozen_string_literal: true


module HmacSignedUrl
  class Error < StandardError; end
  class MissingExpiry < Error; end
  class Expired < Error; end
  class InvalidSignature < Error; end
end