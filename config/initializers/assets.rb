# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w(application-core.js admin.js admin-core.js admin.scss catalog-admin.js catalog-admin-core.js catalog-admin.scss)

# The code below requires an existing database to set up catalog specific assets
# This is not granted in every case, so we recover from an ActiveRecord::NoDatabaseError
# by simply ignoring catalog specific assets
begin
  # Add catalog specific assets to the load path
  Catalog.overrides.each do |slug|
    base_path = Rails.root.join('catalogs', slug, 'assets')
    Rails.application.config.assets.paths += %w(images stylesheets javascripts).map { |asset| base_path.join(asset) }
  end

  # Add catalog-specific assets
  Catalog.overrides.each do |slug|
    Rails.application.config.assets.precompile += ["#{slug}.css", "#{slug}.js"]
    loose_catalog_assets = lambda do |filename, path|
      path =~ %r{catalogs/#{slug}/assets} && !%w(.js .css).include?(File.extname(filename))
    end
    Rails.application.config.assets.precompile << loose_catalog_assets
  end
rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid, ActiveRecord::PendingMigrationError
  false
end
