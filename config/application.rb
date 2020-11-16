require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ViimCore
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Use sidekiq to process Active Jobs (e.g. ActionMailer's deliver_later)
    config.active_job.queue_adapter = :sidekiq

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Bern"

    # We are defining custom procedures, so the default Ruby format won't work.
    config.active_record.schema_format = :sql

    # Ensure non-standard paths are eager-loaded in production
    # (these paths are also autoloaded in development mode)

    # Add catalog-specific controllers to the eager-load path
    if Dir.exist?(config.root.join('catalogs'))
      Dir.entries(config.root.join('catalogs')).each do |catalog|
        if (catalog =~ /[^a-z\-]/).nil? && Dir.exist?(config.root.join('catalogs', catalog, 'controllers'))
          config.eager_load_paths += %W(#{config.root}/catalogs/#{catalog}/controllers)
        end
      end
    end

    # Custom error pages
    config.exceptions_app = routes
  end
end
