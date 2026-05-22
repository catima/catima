require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ViimCore
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # Use sidekiq to process Active Jobs (e.g. ActionMailer's deliver_later)
    config.active_job.queue_adapter = :sidekiq

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    config.time_zone = "Bern"

    # We are defining custom procedures, so the default Ruby format won't work.
    config.active_record.schema_format = :sql

    # Change the format of the cache entry.
    #
    # Changing this default means that all new cache entries added to the cache
    # will have a different format that is not supported by Rails 7.0
    # applications.
    #
    # Only change this value after your application is fully deployed to Rails 7.1
    # and you have no plans to rollback.
    # config.active_support.cache_format_version = 7.1

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

    # Disables the deprecated #to_s override in some Ruby core classes
    # See https://guides.rubyonrails.org/configuring.html#config-active-support-disable-to-s-conversion for more information.
    config.active_support.disable_to_s_conversion = true

    # Custom error pages
    config.exceptions_app = routes
  end
end
