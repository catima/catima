source "https://rubygems.org"

gem "active_model_serializers", "~> 0.10"
gem "active_type", "~> 1.5"
gem "ahoy_matey", "~> 3.1"
gem "autoprefixer-rails", "~> 10.1"
gem "bcrypt", "~> 3.1"
gem "bootstrap", "~> 4.5"
gem "bootstrap_form", "~> 4.3"
gem "bugsnag", "~> 6.18"
gem "chartkick", "~> 3.4"
gem "cocoon", "~> 1.2"
gem "coffee-rails", "~> 5.0"
gem "devise", "~> 4.7"
gem "devise-jwt", "~> 0.8.1"
gem "dotenv-rails", "~> 2.7"
gem "faraday", "~> 1.1"
gem "faraday_middleware", "~> 1.0"
gem "font-awesome-rails", "~> 4.7.0"
gem 'groupdate', "~> 5.2"
gem "jquery-fileupload-rails", "~> 1.0"
gem "jquery-minicolors-rails", "~> 2.2"
gem "jquery-rails", "~> 4.4"
gem "kaminari", "~> 1.2"
gem 'leaflet-rails', "~> 1.7"
gem "mail", "~> 2.7"
gem "marco-polo", "~> 2.0"
gem "mini_magick", "~> 4.11"
gem "nokogiri", "~> 1.12"
gem 'omniauth-oauth2', "~> 1.7"
gem 'omniauth-facebook', "~> 8.0"
gem 'omniauth-github', "~> 1.4"
gem 'omniauth-shibboleth', "~> 1.3"
gem "omniauth-rails_csrf_protection", "~> 0.1" # Mitigation against CVE-2015-9284
gem "panoramic", git: "https://github.com/catima/panoramic.git", branch: "master" # Use a forked version because PR https://github.com/andreapavoni/panoramic/pull/27 isn't bumped on last gem version
gem "pg", "~> 1.2"
gem "pg_search", "~> 2.3"
gem "pgcli-rails", "~> 0.5"
gem "pundit", "~> 2.1"
gem "rails", '~> 6.1'
gem "ranked-model", "~> 0.4"
gem 'react-rails'
gem "recaptcha", "~> 5.6"
gem "redcarpet", "~> 3.5"
gem "refile", github: "refile/refile", require: "refile/rails"
gem "refile-mini_magick", github: "refile/refile-mini_magick"
gem 'sassc-rails', "~> 2.1"
gem "secure_headers", "~> 6.3"
gem "select2-rails", "~> 4.0"
gem "sidekiq", "~> 6.1"
gem "sinatra", "~> 2.1"
gem "sprockets", "~> 4.0"
gem "sprockets-rails", "~> 3.2"
gem "summernote-rails", "~> 0.8"
gem "rubyzip", "~> 2.3"
gem "webpacker", "~> 5.2"
gem "zaru", "~> 0.3"
gem "jbuilder", "~> 2.10.1"
gem "rswag", "~> 2.4.0"
gem 'redis', "~> 4.2.5"
gem "rspec-rails", "~> 5.0.1"

source "https://rails-assets.org" do
  gem "rails-assets-autosize", "~> 4.0"
  gem "rails-assets-mousetrap", "~> 1.6"
end

group :production, :staging, :development do
  platforms :ruby do
    gem "unicorn", "~> 5.7"
  end
end

group :development, :test do
  gem "simplecov", "~> 0.20", :require => false
  gem "byebug", "~> 11.1.3", :require => false
end

group :development do
  gem "annotate", "~> 3.1"
  gem "awesome_print", "~> 1.8"
  gem "bcrypt_pbkdf", "~> 1.0", :require => false
  gem "better_errors", "~> 2.9"
  gem "binding_of_caller", "~> 0.8"
  gem "brakeman", "~> 4.10", :require => false
  gem "faker", "~> 2.15", :require => false
  gem "letter_opener", "~> 1.7"
  gem "listen", "~> 3.3"
  gem "overcommit", "~> 0.57", :require => false
  gem "rainbow", "~> 3.0", :require => false
  gem "rb-fsevent", "~> 0.10", :require => false
  gem "rubocop-rails", "~> 2.9", :require => false
  gem "ruby-progressbar", "~> 1.10", :require => false
  gem "spring", "~> 2.1"
  gem "sshkit", "~> 1.21", :require => false
  gem "terminal-notifier", "~> 2.0", :require => false
  gem "terminal-notifier-guard", "~> 1.7", :require => false
  platforms :mswin, :mingw, :x64_mingw do
    gem "tzinfo-data"
  end
end

group :test do
  gem "capybara", "~> 3.34"
  gem "webdrivers", "~> 4.4"
  gem "connection_pool", "~> 2.2"
  gem "json_schema", "~> 0.20"
  gem "launchy", "~> 2.5"
  gem "minitest-reporters", "~> 1.4"
  gem "mocha", "~> 1.11"
  gem "puma", "~> 5.3"
  gem "pry", "~> 0.13"
  gem "selenium-webdriver", "~> 3.142"
  gem "shoulda-context", "~> 2.0"
  gem "shoulda-matchers", "~> 4.4"
  gem "vcr", "~> 6.0"
  gem "webmock", "~> 3.10"
end
