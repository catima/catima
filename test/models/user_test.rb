require "test_helper"

class UserTest < ActiveSupport::TestCase
  should validate_presence_of(:primary_language)
  should validate_inclusion_of(:primary_language).in_array(%w(de en fr it))
end
