require "test_helper"

class ChoiceTest < ActiveSupport::TestCase
  should validate_presence_of(:choice_set)
  should validate_presence_of(:long_name)
  should validate_presence_of(:short_name)
end
