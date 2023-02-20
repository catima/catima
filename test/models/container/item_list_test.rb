require 'test_helper'

class Container::ItemListTest < ActiveSupport::TestCase
  test "item list container with empty item type should not be valid" do
    container = containers(:one_list_empty_item_type)

    refute container.valid?
  end
end
