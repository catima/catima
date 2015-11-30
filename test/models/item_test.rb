require "test_helper"

class ItemTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:creator)
  should validate_presence_of(:item_type)
end
