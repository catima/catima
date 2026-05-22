# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
Rails.application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'app', '*.{rb,yml}').to_s]

# Add catalog specific translations from catalogs/:catalog_slug/locales/*.yml
# This checks the file system directly without requiring database access
Rails.application.config.to_prepare do
  catalogs_path = Rails.root.join('catalogs')
  if Dir.exist?(catalogs_path)
    catalog_slugs = Dir.entries(catalogs_path).select do |entry|
      # Filter out special directories and only include actual directories
      entry != '.' && entry != '..' && File.directory?(File.join(catalogs_path, entry))
    end

    catalog_slugs.each do |slug|
      Rails.application.config.i18n.load_path += Dir[Rails.root.join('catalogs', slug, 'locales', '*.yml').to_s]
    end
  end
end

Rails.application.config.i18n.default_locale = :en
Rails.application.config.i18n.available_locales = %i(de en fr it)

# TODO: uncomment once Catalog behavior is implemented
# I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
# I18n.fallbacks = Catalog::I18nFallbacks.new
