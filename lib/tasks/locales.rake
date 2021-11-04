# frozen_string_literal: true

require "locales/base"
require "locales/to_js"
require "locales/to_json"
require "active_support"

namespace :locales do
  desc <<-DESC.strip_heredoc
    Generate i18n javascript files
    This task generates javascript locale files: `translations.js` & `default.js` and places them in
    the "Locales.configuration.i18n_dir".
  DESC
  task generate: :environment do
    Locales.compile
  end
end
