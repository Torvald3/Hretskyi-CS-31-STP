# frozen_string_literal: true


require "bundler/setup"               # підтягує залежності з Gemfile в тестовому середовищі
require "rspec"                       # фреймворк тестів
require_relative "../lib/hmac_signed_url"  # підключаємо нашу бібліотеку, щоб у тестах були доступні класи

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect                # стиль очікувань: expect(...).to ...
  end
end

#усі файли spec/*_spec.rb починаються з require "spec_helper", який підтягує бібліотеку.