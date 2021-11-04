# frozen_string_literal: true

require "locales/base"

Locales.configure do |config|
  # Path to the js locale files.
  config.i18n_dir = Rails.root.join("app", "assets", "i18n")

  # Path to the rails locale files.
  config.i18n_yml_dir = Rails.root.join("config", "locales", "app")

  # i18n format
  config.i18n_output_format = 'js'
end
