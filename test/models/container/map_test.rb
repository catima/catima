require 'test_helper'

class Container::MapTest < ActiveSupport::TestCase
  test "map container with empty item type should not be valid" do
    container = containers(:one_map_empty_item_type)

    refute container.valid?
  end

  test "map container retrieve geographic fields correctly" do
    container = containers(:one_map_geofields)

    assert container.geo_fields_as_fields.length == 2
    container.geo_fields_as_fields.each do |field|
      assert field.is_a?(Field::Geometry)
      [fields(:one_author_birthplace), fields(:one_author_home)].include?(field)
    end
  end
end
