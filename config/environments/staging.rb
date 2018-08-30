# Staging configuration is identical to production, with some overrides
# for hostname, etc.

require_relative "./production"

Rails.application.configure do
  config.i18n.fallbacks = false
end
