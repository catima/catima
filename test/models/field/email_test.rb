require "test_helper"

class Field::EmailTest < ActiveSupport::TestCase
  should allow_value("email@example.com").for(:default_value)
  should_not allow_value("garbage").for(:default_value)
end
