source "https://rubygems.org"

gem "active_model_serializers", "~> 0.10"
gem "active_type", "~> 1.5"
gem 'device_detector', '~> 1.1'
gem "ahoy_matey", "~> 5.0.2"
gem "autoprefixer-rails", "~> 10.1"
gem "bcrypt", "~> 3.1"
gem "bootstrap", "~> 4.5"
gem "bootstrap_form", "~> 4.3"
gem "bugsnag", "~> 6.18"
gem "chartkick", "~> 5.0"
gem "cocoon", "~> 1.2"
gem "coffee-rails", "~> 5.0"
gem "devise", "~> 4.9"
gem "devise-jwt", "~> 0.11"
gem "dotenv-rails", "~> 2.7"
gem "faraday", "~> 1.1"
gem "faraday_middleware", "~> 1.0"
gem "font-awesome-rails", "~> 4.7.0"
gem 'groupdate', "~> 6.4"
gem "jquery-fileupload-rails", "~> 1.0"
gem "jquery-minicolors-rails", "~> 2.2"
gem "jquery-rails", "~> 4.4"
gem "kaminari", "~> 1.2"
gem 'leaflet-rails', "~> 1.7"
gem "mail", "~> 2.7"
gem "marco-polo", "~> 2.0"
gem "mini_magick", "~> 4.11"
gem "nokogiri", "~> 1.14"
gem 'omniauth-oauth2', "~> 1.7"
gem 'omniauth-facebook', "~> 8.0"
gem 'omniauth-github', "~> 1.4"
gem 'omniauth-shibboleth', "~> 1.3"
gem "omniauth-rails_csrf_protection", "~> 0.1" # Mitigation against CVE-2015-9284
gem "panoramic", git: "https://github.com/andreapavoni/panoramic.git", branch: "master"
gem "pg", "~> 1.2"
gem "pg_search", "~> 2.3"
gem "pgcli-rails", "~> 0.5"
gem "pundit", "~> 2.1"
gem "rails", '~> 7.0.8'
gem "ranked-model", "~> 0.4"
gem 'react-rails', "~> 2.6"
gem "recaptcha", "~> 5.6"
gem "redcarpet", "~> 3.6"
# Use a forked version of refile because main repository is not actively
# maintained anymore and is not compatible with ruby 3.x
gem "refile", git: "https://github.com/catima/refile", tag: "0.6.9", require: "refile/rails"
gem "refile-mini_magick", github: "refile/refile-mini_magick"
gem 'sassc-rails', "~> 2.1"
gem "secure_headers", "~> 6.3"
gem "select2-rails", "~> 4.0"
gem "shakapacker", "7.1"
gem "sidekiq", "~> 7.1"
gem "sinatra", "~> 2.2"
gem "sprockets", "~> 4.0"
gem "summernote-rails", "~> 0.8"
gem "rubyzip", "~> 2.3"
gem "zaru", "~> 0.3"
gem "jbuilder", "~> 2.11.5"
gem "rswag", "~> 2.11.0"
gem 'redis', "~> 5.0"
gem "rspec-rails", "~> 6.0.3"
gem "net-http", "~> 0.4" # Avoid already initialized constant Net::ProtocRetryError

source "https://rails-assets.org" do
  gem "rails-assets-autosize", "~> 4.0"
  gem "rails-assets-mousetrap", "~> 1.6"
end

group :production, :staging, :development do
  platforms :ruby do
    gem "unicorn", "~> 6.1"
  end
end

group :development, :test do
  gem "simplecov", "~> 0.22", :require => false
  gem "byebug", "~> 11.1.3"
  gem "selenium-webdriver", "~> 4.14.0"
end

group :development do
  gem "annotate", "~> 3.1"
  gem "awesome_print", "~> 1.8"
  gem "bcrypt_pbkdf", "~> 1.0", :require => false
  gem "better_errors", "~> 2.9"
  gem "binding_of_caller", "~> 1.0"
  gem "brakeman", "~> 6.0", :require => false
  gem "faker", "~> 2.15", :require => false
  gem "letter_opener", "~> 1.7"
  gem "listen", "~> 3.3"
  gem "overcommit", "~> 0.57", :require => false
  gem "rainbow", "~> 3.0", :require => false
  gem "rb-fsevent", "~> 0.10", :require => false
  gem "rubocop-rails", "~> 2.9", :require => false
  gem "ruby-progressbar", "~> 1.10", :require => false
  gem "spring", "~> 4.1.2"
  gem "sshkit", "~> 1.21", :require => false
  gem "terminal-notifier", "~> 2.0", :require => false
  gem "terminal-notifier-guard", "~> 1.7", :require => false
  platforms :mswin, :mingw, :x64_mingw do
    gem "tzinfo-data"
  end
end

group :test do
  gem "capybara", "~> 3.34"
  gem "connection_pool", "~> 2.2"
  gem "json_schema", "~> 0.20"
  gem "launchy", "~> 2.5"
  gem "minitest-reporters", "~> 1.6"
  gem "mocha", "~> 2.1"
  gem "puma", "~> 6.4"
  gem "pry", "~> 0.13"
  gem "shoulda-context", "~> 2.0"
  gem "shoulda-matchers", "~> 5.1"
  gem "vcr", "~> 6.0"
  gem "webmock", "~> 3.10"
end
