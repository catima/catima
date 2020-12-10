source "https://rubygems.org"

gem "active_model_serializers", "~> 0.10.7"
gem "active_type", ">= 0.7.5"
gem "ahoy_matey", "~> 3.0.1"
gem "autoprefixer-rails", "~> 9.7.3"
gem "bcrypt", "~> 3.1.13"
gem "bootstrap-sass", "~> 3.4.1" # TODO: Replace by https://github.com/twbs/bootstrap-rubygem for bootstrap 4
gem "bootstrap_form", "~> 2.7.0" # TODO: Upgrade to 4.3.0 for rails6 (only compatible with bootstrap 4)
gem "bugsnag", "~> 6.17"
gem "chartkick", "~> 3.4.0"
gem "cocoon"
gem "coffee-rails", "~> 5.0.0"
gem "devise", "~> 4.7"
gem "dotenv-rails", ">= 2.5.0"
gem "faraday", "~> 1.0.0"
gem "faraday_middleware", "~> 1.0.0"
gem "font-awesome-rails", '~> 4.7.0.5'
gem 'groupdate', "~> 4.1.2"
gem "jquery-fileupload-rails"
gem "jquery-minicolors-rails", '~> 2.2.6.2'
gem "jquery-rails", '~> 4.3.5'
gem "jquery-turbolinks"
gem "kaminari", '~> 1.2.1'
gem 'leaflet-rails', '~> 1.5.0'
gem "mail", ">= 2.7.0"
gem "marco-polo"
gem "mini_magick", '~> 4.9.5'
gem "mini_racer", '~> 0.3', platforms: :ruby
gem "nokogiri"
gem 'omniauth-oauth2', "~> 1.6.0"
gem 'omniauth-facebook', "~> 5.0.0"
gem 'omniauth-github', "~> 1.3.0"
gem 'omniauth-shibboleth', "~> 1.3.0"
gem "omniauth-rails_csrf_protection", "~> 0.1.2" # Mitigation against CVE-2015-9284
gem "panoramic"
gem "pg", "~> 1.1.4"
gem "pg_search", "~> 2.3.0"
gem "pgcli-rails", "~> 0.3.0"
gem "pundit", "~> 2.1.0"
gem "rails", "~> 5.2.4"
gem "ranked-model"
gem "react_on_rails", "~> 11.3.0"
gem "recaptcha", "~> 5.1.0"
gem "redcarpet", "~> 3.5.0"
gem "refile", github: "refile/refile", require: "refile/rails"
gem "refile-mini_magick", github: "refile/refile-mini_magick"
gem "sassc-rails", "~> 2.1.2"
gem "secure_headers"
gem "select2-rails"
gem "sidekiq", "~> 6.0.0"
gem "sinatra", "~> 2.0.8.1"
gem "sprockets", "~> 3.7.2"
gem "sprockets-rails", "~> 3.2.1"
gem "summernote-rails", "~> 0.8.12.0"
gem "rubyzip", "~> 2.0.0"
gem "webpacker", "~> 5.1.1"
gem "zaru"

source "https://rails-assets.org" do
  gem "rails-assets-autosize"
  gem "rails-assets-mousetrap"
end

group :production, :staging, :development do
  platforms :ruby do
    gem "unicorn"
  end
end

group :development, :test do
  gem "simplecov", :require => false
end

group :development do
  gem "annotate"
  gem "awesome_print"
  gem "bcrypt_pbkdf", :require => false
  gem "better_errors"
  gem "binding_of_caller"
  gem "brakeman", :require => false
  gem "faker", :require => false
  gem "letter_opener"
  gem "listen"
  gem "overcommit", :require => false
  gem "rainbow", :require => false
  gem "rb-fsevent", :require => false
  gem "rubocop-rails", :require => false
  gem "ruby-progressbar", :require => false
  gem "spring"
  gem "sshkit", :require => false
  gem "terminal-notifier", :require => false
  gem "terminal-notifier-guard", :require => false
  gem "thin", :require => false

  platforms :mswin, :mingw, :x64_mingw do
    gem "tzinfo-data"
  end
end

group :test do
  gem "capybara", "~> 3.31.0"
  gem "webdrivers", "~> 4.1.3"
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
  gem "vcr"
  gem "webmock", "~> 3.8.0"
end
