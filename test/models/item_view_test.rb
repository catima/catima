require 'test_helper'

class ItemViewTest < ActiveSupport::TestCase
  should validate_presence_of(:item_type)
  should validate_presence_of(:name)
  should validate_presence_of(:template)
end
