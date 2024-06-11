# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.1'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.6'
gem 'activestorage', '~> 7.0.8'
gem 'actionpack', '~> 7.0.7'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use Postgres as the database for Active Record
gem 'pg'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.6.8'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Text Completion
gem 'ruby-openai'

# Use Sass to process CSS
gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'annotate', '~> 3.2'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'webdrivers'

  # Security Checks  
  gem "bundler-audit", "~> 0.9.1"
  gem "brakeman", "~> 6.1"
  # Style Linting
  # gem 'rubocop'
  # gem "rubocop-rails", "~> 2.24"
  # gem "rubocop-capybara", "~> 2.20"
end

gem 'actiontext'
gem 'http', '~> 5.1'
gem 'trix'
gem 'trix-rails'

gem 'pdf-reader', '~> 2.11'

gem 'open-uri', '~> 0.3.0'

gem 'bootstrap', '~> 5.3'

gem 'docx', '~> 0.8.0'

gem 'google-cloud-firestore'


