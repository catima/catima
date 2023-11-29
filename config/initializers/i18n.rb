# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
Rails.application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'app', '*.{rb,yml}').to_s]

# Add catalog specific translations from catalogs/:catalog_slug/locales/*.yml
# This requires the database to exist. If it does not exist, we recover without
# adding catalog specific translations.
Rails.application.config.to_prepare do
  Catalog.overrides.each do |slug|
    Rails.application.config.i18n.load_path += Dir[Rails.root.join('catalogs', slug, 'locales', '*.yml').to_s]
  end
rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid, ActiveRecord::PendingMigrationError
  false
end

Rails.application.config.i18n.default_locale = :en
Rails.application.config.i18n.available_locales = %i(de en fr it)

# TODO: uncomment once Catalog behavior is implemented
# I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
# I18n.fallbacks = Catalog::I18nFallbacks.new
