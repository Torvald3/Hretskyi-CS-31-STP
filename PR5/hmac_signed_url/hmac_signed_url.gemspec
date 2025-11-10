# frozen_string_literal: true


Gem::Specification.new do |s|
s.name = "hmac_signed_url"
s.version = "0.1.0"
s.summary = "HMAC-підпис і валідація підписаних URL із TTL"
s.description = "Простий і надійний спосіб генерувати та перевіряти підписані URL з параметром exp (TTL) та сигнатурою sig (HMAC-SHA256)."
s.authors = ["Hretskyi"]
s.email = ["aaaa@example.com"]
s.files = Dir["lib/**/*.rb", "README.md", "examples/**/*", "bin/**/*"]
s.homepage = ""
s.license = "MIT"
s.add_dependency "base64"

s.required_ruby_version = ">= 2.7"


s.metadata = {
"source_code_uri" => "",
"changelog_uri" => ""
}


s.add_development_dependency "rspec", "~> 3.12"


s.bindir = "bin"
s.executables = ["console"]
end