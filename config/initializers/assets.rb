# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add catalog specific assets to the load path
unless ActiveRecord::Migrator.needs_migration?
  Catalog.overrides.each do |slug|
    base_path = Rails.root.join('catalogs', slug, 'assets')
    Rails.application.config.assets.paths += %w(images stylesheets javascripts).map { |asset| base_path.join(asset) }
  end
end

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

# Add catalog-specific assets
unless ActiveRecord::Migrator.needs_migration?
  Catalog.overrides.each do |slug|
    Rails.application.config.assets.precompile += ["#{slug}.css", "#{slug}.js"]
    loose_catalog_assets = lambda do |filename, path|
      path =~ %r{catalogs/#{slug}/assets} && !%w(.js .css).include?(File.extname(filename))
    end
    Rails.application.config.assets.precompile << loose_catalog_assets
  end
end
