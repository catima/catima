require "test_helper"

class Field::URLTest < ActiveSupport::TestCase
  should allow_value("https://google.com/").for(:default_value)
  should_not allow_value("google.com").for(:default_value)
end
