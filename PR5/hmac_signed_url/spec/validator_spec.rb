# frozen_string_literal: true
require "spec_helper"

RSpec.describe HmacSignedUrl::Validator do
  let(:secret) { "test-secret" }


  before do
  HmacSignedUrl.configure do |c|
  c.secret = secret
  c.default_ttl = 60
  c.http_method = "GET"
  end
  end


  it "валидає валідний URL" do
    base = "https://example.com/files?name=a.txt"
    signer = HmacSignedUrl::Signer.new
    signed = signer.sign(base, ttl: 30)


    validator = described_class.new
    expect(validator.valid?(signed)).to be true
  end


  it "відхиляє протермінований URL" do
    base = "https://example.com/files?name=a.txt"
    signer = HmacSignedUrl::Signer.new
    t = Time.now.to_i - 10 # уже минув
    signed = signer.sign(base, expires_at: t)


    validator = described_class.new
    expect(validator.valid?(signed)).to be false
    expect { validator.valid!(signed) }.to raise_error(HmacSignedUrl::Expired)
  end


  it "відхиляє підроблений параметр" do
    base = "https://example.com/files?name=a.txt"
    signer = HmacSignedUrl::Signer.new
    signed = signer.sign(base, ttl: 30)


    tampered = signed.sub("name=a.txt", "name=b.txt")


    validator = described_class.new
    expect(validator.valid?(tampered)).to be false
    expect { validator.valid!(tampered) }.to raise_error(HmacSignedUrl::InvalidSignature)
  end


  it "відхиляє при неправильному секреті" do
    base = "https://example.com/files?name=a.txt"
    signer = HmacSignedUrl::Signer.new
    signed = signer.sign(base, ttl: 30)


    HmacSignedUrl.configure { |c| c.secret = "other-secret" }


    validator = described_class.new
    expect(validator.valid?(signed)).to be false
  end
end