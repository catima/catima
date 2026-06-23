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

  test "map container retrieve zoom level correctly" do
    container = containers(:one_map_geofields)

    # By default, zoom_level is Field::Geometry::ZOOM_LEVEL['medium'] (which evaluates to 10)
    assert_equal Field::Geometry::ZOOM_LEVEL['medium'], container.zoom_level

    # Can set a custom zoom level
    container.zoom = Field::Geometry::ZOOM_LEVEL['close']
    assert_equal Field::Geometry::ZOOM_LEVEL['close'], container.zoom_level
  end

  test "map container zoom level must be an integer" do
    container = containers(:one_map_geofields)

    container.zoom = 10.5
    refute container.valid?

    container.zoom = "abc"
    refute container.valid?
  end

  test "map container zoom level must be within range" do
    container = containers(:one_map_geofields)

    container.zoom = Field::Geometry::ZOOM_LEVEL['distant'] - 1
    refute container.valid?

    container.zoom = Field::Geometry::ZOOM_LEVEL['close'] + 1
    refute container.valid?

    container.zoom = Field::Geometry::ZOOM_LEVEL['medium']
    assert container.valid?
  end
end
