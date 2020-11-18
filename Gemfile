source "https://rubygems.org"

gem "active_model_serializers"
gem "active_type"
gem "ahoy_matey"
gem "autoprefixer-rails"
gem "bcrypt"
gem "bootstrap-sass", "~> 3.4.1" # TODO: Replace by https://github.com/twbs/bootstrap-rubygem for bootstrap 4
gem "bootstrap_form", "~> 2.7.0" # TODO: Upgrade to 4.3.0 for rails6 (only compatible with bootstrap 4)
gem "bugsnag"
gem "chartkick"
gem "cocoon"
gem "coffee-rails"
gem "devise"
gem "dotenv-rails"
gem "faraday"
gem "faraday_middleware"
gem "font-awesome-rails"
gem 'groupdate'
gem "jquery-fileupload-rails"
gem "jquery-minicolors-rails"
gem "jquery-rails"
gem "kaminari"
gem 'leaflet-rails'
gem "mail"
gem "marco-polo"
gem "mini_magick"
gem "mini_racer"
gem "nokogiri"
gem 'omniauth-oauth2'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-shibboleth'
gem "omniauth-rails_csrf_protection", "~> 0.1.2" # Mitigation against CVE-2015-9284
gem "panoramic", git: "https://github.com/andreapavoni/panoramic.git", branch: "c14036efaa13f58c390731606dc477804d773d6e" # Fixed commit version while waiting for the PR https://github.com/andreapavoni/panoramic/pull/27 to be merged on the next gem version
gem "pg"
gem "pg_search"
gem "pgcli-rails"
gem "pundit"
gem "rails", '~> 6.0.3'
gem "ranked-model"
gem "react_on_rails", "~> 11.3.0"
gem "recaptcha"
gem "redcarpet"
gem "refile", github: "refile/refile", require: "refile/rails"
gem "refile-mini_magick", github: "refile/refile-mini_magick"
gem 'sassc-rails'
gem "secure_headers"
gem "select2-rails"
gem "sidekiq"
gem "sinatra"
gem "sprockets"
gem "sprockets-rails"
gem "summernote-rails"
gem "rubyzip"
gem "webpacker"
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

  platforms :mswin, :mingw, :x64_mingw do
    gem "tzinfo-data"
  end
end

group :test do
  gem "capybara"
  gem "webdrivers"
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
  gem "webmock"
end
