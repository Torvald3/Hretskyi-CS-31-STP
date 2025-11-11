# frozen_string_literal: true
require "spec_helper"

RSpec.describe HmacSignedUrl::Signer do #відкриває групу прикладів (test suite) для класу HmacSignedUrl::Signer. Всередині всі it стосуються саме підписувача URL.
  let(:secret) { "test-secret" }                 # фіксований секрет для передбачуваних підписів

  before do
    HmacSignedUrl.configure do |c|
      c.secret = secret                          # конфігуруємо секрет, ttl тощо
      c.default_ttl = 60
      c.http_method = "GET"
    end
  end

  it "додає exp і sig у URL" do
    url = "https://example.com/path?x=1"
    signed = described_class.new.sign(url, ttl: 10)
    #Assert
    expect(signed).to include("exp=")            # перевіряємо, що exp присутній
    expect(signed).to include("sig=")            # перевіряємо, що sig присутній
  end

  it "стабільно підписує незалежно від порядку параметрів" do
    s = described_class.new
    t = Time.now.to_i + 10                       # фіксований exp => підпис має збігатися
    a = s.sign("https://ex.com/p?a=1&b=2", expires_at: t)
    b = s.sign("https://ex.com/p?b=2&a=1", expires_at: t)
    expect(URI(a).query).to include(URI(b).query.split("&").find { _1.start_with?("sig=") })
  end
end
