require "test_helper"
require_dependency("field/geometry")

class Field::GeometryTest < ActiveSupport::TestCase
  #should_not allow_value('{"malformed"').for(:default_value)
  #should_not allow_value('{"not": "GeoJSON"}').for(:default_value)

  test "stores JSON text as Hash" do
    text = '{"type":"Point","coordinates":[-48.23456,20.12345]}'
    item = Item.new(:item_type => item_types(:one_author))
    item.behaving_as_type.one_author_birthplace_uuid_json = text

    stored = item.behaving_as_type.one_author_birthplace_uuid
    assert_instance_of(Hash, stored)
    assert_equal(JSON.parse(text), stored)
  end

  # TODO: Enable JSON validation again
  # test "validates JSON" do
  #   text = '{"type":"Point","coordinates":[-48.23456,20.12345}'
  #   item = Item.new(:item_type => item_types(:one_author)).behaving_as_type
  #   item.one_author_birthplace_uuid_json = text

  #   refute(item.valid?)
  #   refute_nil(item.errors[:one_author_birthplace_uuid_json].first)
  # end

  # test "rejects invalid geometry this is nonetheless syntactically OK" do
  #   text = <<-JSON
  #     {
  #       "type": "Polygon",
  #       "coordinates": [
  #         [[0,0], [2,1], [2,2], [0,0]],
  #         [[0,0], [-1,-1], [-1,1], [0,0]]
  #       ]
  #     }
  #   JSON
  #   item = Item.new(:item_type => item_types(:one_author)).behaving_as_type
  #   item.one_author_birthplace_uuid_json = text

  #   refute(item.valid?)
  #   refute_nil(item.errors[:one_author_birthplace_uuid_json].first)
  # end

  # test "doesn't store JSON if invalid" do
  #   text = '{"type":"Point","coordinates":[-48.23456,20.12345}'
  #   item = Item.new(:item_type => item_types(:one_author))
  #   item.behaving_as_type.one_author_birthplace_uuid_json = text

  #   stored = item.behaving_as_type.one_author_birthplace_uuid
  #   assert_nil(stored)
  # end

  # test "retains user input when invalid" do
  #   text = '{"type":"Point","coordinates":[-48.23456,20.12345}'
  #   item = Item.new(:item_type => item_types(:one_author))
  #   item.behaving_as_type.one_author_birthplace_uuid_json = text

  #   input = item.behaving_as_type.one_author_birthplace_uuid_json
  #   assert_equal(text, input)
  # end
end
