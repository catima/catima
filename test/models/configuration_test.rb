require "test_helper"

class ConfigurationTest < ActiveSupport::TestCase
  should validate_presence_of(:root_mode)
  should validate_inclusion_of(:root_mode).in_array(%w(listing custom redirect))
end
