require "test_helper"

class ItemTypeTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:label)
  should validate_presence_of(:slug)

  should validate_uniqueness_of(:slug).scoped_to(:catalog_id)
  should allow_value("hey").for(:slug)
  should_not allow_value("under_score").for(:slug)
end
