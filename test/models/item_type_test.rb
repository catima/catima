require "test_helper"

class ItemTypeTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:label)
  should validate_presence_of(:slug)

  should validate_uniqueness_of(:slug)
end
