# This has to come first
require 'simplecov'
SimpleCov.start
require_relative "./support/rails"

# Load everything else from test/support
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |rb| require(rb) }
