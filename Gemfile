source "https://rubygems.org"

gem "active_model_serializers", "~> 0.10.7"
gem "active_type", ">= 0.7.5"
gem "autoprefixer-rails", ">= 8.6.4"
gem "bcrypt", "~> 3.1.12"
gem "bootstrap-sass", "~> 3.3.7"
gem "bootstrap_form", "~> 2.7.0"
gem "cocoon"
gem "coffee-rails", "~> 4.2.2"
gem "devise", "~> 4.4"
gem "dotenv-rails", ">= 2.5.0"
gem "faraday"
gem "faraday_middleware"
gem "font-awesome-rails"
gem "jquery-fileupload-rails"
gem "jquery-minicolors-rails"
gem "jquery-rails"
gem "jquery-turbolinks"
gem "kaminari"
gem 'leaflet-rails', '~> 1.3.1'
gem "liquid"
gem "liquid-rails"
gem "mail", ">= 2.7.0"
gem "marco-polo"
gem "mini_magick"
gem "mini_racer", platforms: :ruby
gem "nokogiri"
gem 'omniauth-oauth2'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-shibboleth'
gem "panoramic"
gem "pg", "~> 1.0"
gem "pg_search", "~> 2.1.2"
gem "pgcli-rails", "~> 0.3.0"
gem "pundit"
gem "rails", "~> 5.2.0"
gem "ranked-model"
gem "react_on_rails", "~> 11.0.9"
gem "redcarpet"
gem "redis-namespace"
gem "refile", github: "refile/refile", require: "refile/rails"
gem "refile-mini_magick", github: "refile/refile-mini_magick"
gem "rollbar"
gem "sass-rails"
gem "secure_headers"
gem "select2-rails"
gem "sidekiq"
gem "sinatra", github: "sinatra/sinatra", branch: "master"
gem "sprockets"
gem "sprockets-rails"
gem "summernote-rails"
gem "rubyzip", "~> 1.2.2"
gem "webpacker"
gem "zaru"

source "https://rails-assets.org" do
  gem "rails-assets-autosize"
  gem "rails-assets-mousetrap"
end

group :production, :staging, :development do
  gem "unicorn"
end

group :production, :staging do
  gem "unicorn-worker-killer"
end

group :development, :test do
  gem "simplecov", :require => false
end

group :development do
  gem "airbrussh", :require => false
  gem "annotate"
  gem "awesome_print"
  gem "bcrypt_pbkdf", :require => false
  gem "better_errors"
  gem "binding_of_caller"
  gem "brakeman", :require => false
  gem "bundler-audit", :require => false
  gem "capistrano", :require => false
  gem "capistrano-bundler", :require => false
  gem "capistrano-mb", :require => false
  gem "capistrano-nc", :require => false
  gem "capistrano-rails", :require => false
  gem "faker", :require => false
  gem "letter_opener"
  gem "listen"
  gem "overcommit", :require => false
  gem "rainbow", :require => false
  gem "rb-fsevent", :require => false
  gem "rbnacl", :require => false
  gem "rbnacl-libsodium", :require => false
  gem "rubocop", :require => false
  gem "ruby-progressbar", :require => false
  gem "spring"
  gem "sshkit", :require => false
  gem "terminal-notifier", :require => false
  gem "terminal-notifier-guard", :require => false
  gem "thin", :require => false
  # gem "xray-rails"
end

group :test do
  gem "capybara"
  gem "chromedriver-helper"
  gem "connection_pool"
  gem "json_schema"
  gem "launchy"
  gem "minitest-reporters"
  gem "mocha"
  gem "puma"
  gem "pry"
  gem "selenium-webdriver"
  gem "shoulda-context"
  gem "shoulda-matchers"
  # gem "shoulda-matchers",
  #     :git => "https://github.com/mattbrictson/shoulda-matchers.git",
  #     :branch => "with-fixes"
  gem "vcr"
  gem "webmock"
end
