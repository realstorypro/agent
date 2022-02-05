# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

gem 'bootsnap', require: false
gem 'customerio'
gem 'httparty'
gem 'jsonb_accessor'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.1'
gem 'redis', '~> 4.0'

group :development, :test do
  gem 'byebug'
  gem 'clipboard'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

group :development do
  gem 'spring'
end

gem 'annotate', '~> 2.6'
