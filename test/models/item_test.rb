require "test_helper"

class ItemTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:creator)
  should validate_presence_of(:item_type)

  should validate_inclusion_of(:review_status).in_array(%w(ready rejected approved))
  should allow_value(nil).for(:review_status)
end
