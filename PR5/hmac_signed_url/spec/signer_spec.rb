# frozen_string_literal: true
require "spec_helper"

RSpec.describe HmacSignedUrl::Signer do
  let(:secret) { "test-secret" }


  before do
    HmacSignedUrl.configure do |c|
      c.secret = secret
      c.default_ttl = 60
      c.http_method = "GET"
    end
  end


  it "додає exp і sig у URL" do
    url = "https://example.com/path?x=1"
    signed = described_class.new.sign(url, ttl: 10)
    expect(signed).to include("exp=")
    expect(signed).to include("sig=")
  end


  it "стабільно підписує незалежно від порядку параметрів" do
    s = described_class.new
    a = s.sign("https://ex.com/p?a=1&b=2", ttl: 10)
    b = s.sign("https://ex.com/p?b=2&a=1", ttl: 10)


    # якщо час exp однаковий — підписи збігатимуться
    # для цього зафіксуємо expires_at
    t = Time.now.to_i + 10
    a = s.sign("https://ex.com/p?a=1&b=2", expires_at: t)
    b = s.sign("https://ex.com/p?b=2&a=1", expires_at: t)
    expect(URI(a).query).to include(URI(b).query.split("&").find { _1.start_with?("sig=") })
  end
end