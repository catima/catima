# This has to come first
unless ENV['NO_COVERAGE']
  require 'simplecov'
  SimpleCov.start
end
require_relative "./support/rails"

# Load everything else from test/support
Dir[File.expand_path("../support/**/*.rb", __FILE__)].sort.each { |rb| require(rb) }
