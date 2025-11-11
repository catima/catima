# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# The code below sets up catalog specific assets without requiring database access
# It simply checks for existing catalog directories in the file system
Rails.application.config.to_prepare do
  catalogs_path = Rails.root.join('catalogs')
  if Dir.exist?(catalogs_path)
    catalog_slugs = Dir.entries(catalogs_path).select do |entry|
      # Filter out special directories and only include actual directories
      entry != '.' && entry != '..' && File.directory?(File.join(catalogs_path, entry))
    end

    catalog_slugs.each do |slug|
      # Add catalog specific assets to the load path
      base_path = Rails.root.join('catalogs', slug, 'assets')
      Rails.application.config.assets.paths += %w(images stylesheets javascripts).map { |asset| base_path.join(asset) }

      # Add catalog-specific assets
      Rails.application.config.assets.precompile += %W[#{slug}.css #{slug}.js]
    end
  end
end
