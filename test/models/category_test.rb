require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:name)
end
