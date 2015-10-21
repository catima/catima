source "https://rubygems.org"

gem "active_type", ">= 0.3.2"
gem "autoprefixer-rails", ">= 5.0.0.1"
gem "bcrypt", "~> 3.1.7"
gem "bootstrap_form", "~> 2.3.0"
gem "bootstrap-sass", "~> 3.2.0"
gem "coffee-rails", "~> 4.1.0"
gem "devise"
gem "dotenv-rails", ">= 2.0.0"
gem "font-awesome-rails"
gem "jquery-rails"
gem "jquery-turbolinks"
gem "mail", ">= 2.6.3"
gem "marco-polo"
gem "pg", "~> 0.18"
gem "pundit"
gem "rails", "4.2.4"
gem "ranked-model"
gem "refile", "~> 0.6.1", :require => "refile/rails"
gem "refile-mini_magick"
gem "rollbar", "~> 2.3"
gem "sass-rails", "~> 5.0"
gem "secure_headers", ">= 2.1.0"
gem "sidekiq"
gem "sinatra", ">= 1.3.0", :require => false
gem "turbolinks", ">= 2.5.2"

source "https://rails-assets.org" do
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
  gem "capistrano-rails", :require => false
  gem "guard", ">= 2.2.2", :require => false
  gem "guard-livereload", :require => false
  gem "guard-minitest", :require => false
  gem "rb-fsevent", :require => false
  gem "simplecov", :require => false
  gem "sshkit", "~> 1.7.1", :require => false
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
  gem "shoulda"
  gem "test_after_commit"
end
