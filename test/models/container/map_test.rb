require 'test_helper'

class Container::MapTest < ActiveSupport::TestCase
  test "map container with empty item type should not be valid" do
    container = containers(:one_map_empty_item_type)

    refute container.valid?
  end
end
