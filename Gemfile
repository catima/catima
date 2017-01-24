source "https://rubygems.org"

gem "active_type", ">= 0.6.0"
gem "autoprefixer-rails", ">= 6.4.1.1"
gem "bcrypt", "~> 3.1.10"
gem "bootstrap_form", "~> 2.3.0"
gem "bootstrap-sass", "~> 3.2.0"
gem "cocoon"
gem "coffee-rails", "~> 4.1.0"
gem "devise", "~> 4.2"
gem "disable_with_spinner", "~> 0.0.3"
gem "dotenv-rails", ">= 2.0.0"
gem "dropzonejs-rails", "~> 0.7.3"
gem "faraday", "~> 0.9.2"
gem "faraday_middleware", "~> 0.10.0"
gem "font-awesome-rails"
gem "jquery-rails"
gem "jquery-turbolinks"
gem "kaminari"
gem "liquid-rails", ">= 0.1.3"
gem "mail", ">= 2.6.3"
gem "marco-polo"
gem 'mini_magick', '~> 4.3.6'
gem "panoramic", ">= 0.0.6"
gem "pg", "~> 0.19"
gem "pg_search", "~> 1.0"
gem "pundit"
gem "rails", "~> 4.2.7.1"
gem "ranked-model"
gem 'react-rails', '~> 1.10.0'
gem "redis-namespace"
gem "redcarpet"
gem "refile", "~> 0.6.1", :require => "refile/rails"
gem "refile-mini_magick"
gem "rollbar", "~> 2.12"
gem "sass-rails", "~> 5.0"
gem "secure_headers", "~> 2.4.4"
gem "select2-rails", "~> 4.0"
gem "sidekiq"
gem "sinatra", ">= 1.3.0", :require => false
gem "sprockets", "~> 3.4"
gem "sprockets-rails", "~> 2.3"
gem "summernote-rails", "~> 0.7.1"
gem "turbolinks", "~> 2.5"

source "https://rails-assets.org" do
  gem "rails-assets-autosize", "~> 3.0.14"
  gem "rails-assets-mousetrap", "~> 1.5.3"
end

group :production, :staging do
  gem "unicorn"
  gem "unicorn-worker-killer"
end

group :development do
  gem "annotate", ">= 2.5.0"
  gem "awesome_print"
  gem "better_errors"
  gem "binding_of_caller"
  gem "letter_opener"
  gem "listen"
  gem "quiet_assets"
  gem "rack-livereload"
  gem "spring"
  gem "xray-rails", ">= 0.1.16"
end

group :development do
  gem "airbrussh", :require => false
  gem "brakeman", :require => false
  gem "bundler-audit", :require => false
  gem "capistrano", "~> 3.4.0", :require => false
  gem "capistrano-bundler", :require => false
  gem "capistrano-mb", ">= 0.22.2", :require => false
  gem "capistrano-nc", :require => false
  gem "capistrano-rails", :require => false
  gem "faker", :require => false, :git => "https://github.com/stympy/faker.git"
  gem "guard", ">= 2.2.2", :require => false
  gem "guard-livereload", :require => false
  gem "guard-minitest", :require => false
  gem "overcommit", :require => false
  gem "rainbow", "~> 2.1.0", :require => false
  gem "rubocop", :require => false
  gem "ruby-progressbar", :require => false
  gem "rb-fsevent", :require => false
  gem "simplecov", :require => false
  gem "sshkit", "~> 1.7", :require => false
  gem "terminal-notifier", :require => false
  gem "terminal-notifier-guard", :require => false
  gem "thin", :require => false
end

group :test do
  gem "capybara"
  gem "connection_pool"
  gem "launchy"
  gem "minitest-reporters"
  gem "mocha"
  gem "poltergeist"
  gem "shoulda-context"
  gem "shoulda-matchers",
      :git => "https://github.com/mattbrictson/shoulda-matchers.git",
      :branch => "with-fixes"
  gem "test_after_commit"
  gem "vcr", "~> 3.0"
  gem "webmock"
end
