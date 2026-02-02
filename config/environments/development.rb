require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Verifies if the expected JS package manager is available
  config.shakapacker.check_manager = true

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Adds the ability to raise errors on missing callback actions
  config.action_controller.raise_on_missing_callback_actions = true

  # Allow requests from localhost and the dynamically generated domain
  config.action_controller.forgery_protection_origin_check = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  # https://guides.rubyonrails.org/v7.1/configuring.html#config-server-timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :redis_cache_store, {
      url: "redis://#{ENV.fetch('REDIS_HOST', 'localhost')}:#{ENV.fetch('REDIS_PORT', '6379')}/#{ENV.fetch('REDIS_SESSION_DB', '1')}",
      namespace: 'catima_cache',
      expires_in: 90.minutes
    }
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :redis_cache_store, {
      url: "redis://#{ENV.fetch('REDIS_HOST', 'localhost')}:#{ENV.fetch('REDIS_PORT', '6379')}/#{ENV.fetch('REDIS_SESSION_DB', '1')}",
      namespace: 'catima_cache',
      expires_in: 90.minutes
    }
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Ensure mailer works in local development
  config.action_mailer.delivery_method = :letter_opener

  # Ensure mailer works in docker
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('MAIL_SMTP_ADDRESS', 'catima-mailhog'),
    port: ENV.fetch('MAIL_SMTP_PORT', '1025')
  }

  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.default_url_options = {
    host: ENV.fetch('DOMAIN', 'localhost:3000'),
    protocol: ENV.fetch('PROTOCOL', 'http')
  }

  config.action_mailer.asset_host = ENV.fetch('ASSET_HOST', 'http://localhost:3000')

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Allow all hosts
  config.hosts.clear

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true
end

# For building URLs in API resource links
Rails.application.routes.default_url_options = {
  :host => ENV.fetch('DOMAIN', 'localhost:3000'),
  :protocol => ENV.fetch('PROTOCOL', 'http')
}
