# frozen_string_literal: true


Gem::Specification.new do |s|
s.name = "hmac_signed_url"
s.version = "0.1.0"
s.summary = "HMAC-підпис і валідація підписаних URL із TTL"
s.description = "Простий і надійний спосіб генерувати та перевіряти підписані URL з параметром exp (TTL) та сигнатурою sig (HMAC-SHA256)."
s.authors = ["Danylo Hretskyi"]
s.email = ["danylo.hretskyi@student.karazin.ua"]
s.files = Dir["lib/**/*.rb", "README.md", "examples/**/*", "bin/**/*"]
s.homepage = "https://github.com/Torvald3/Hretskyi-CS-31-STP"
s.license = "MIT"
s.add_dependency "base64", "~> 0.3"

s.required_ruby_version = ">= 2.7"


s.metadata = {
"source_code_uri" => "https://github.com/Torvald3/Hretskyi-CS-31-STP",
"changelog_uri" => "https://github.com/Torvald3/Hretskyi-CS-31-STP/blob/main/PR5/hmac_signed_url/CHANGELOG.md"
}


s.add_development_dependency "rspec", "~> 3.12"
s.add_development_dependency "webrick", "~> 1.8"


s.bindir = "bin"
s.executables = ["console"]
end