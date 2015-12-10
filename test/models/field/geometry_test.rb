require "test_helper"
require_dependency("field/geometry")

class Field::GeometryTest < ActiveSupport::TestCase
  test "stores JSON text as Hash" do
    text = '{"type":"Point","coordinates":[-48.23456,20.12345]}'
    item = Item.new(:item_type => item_types(:one_author))
    item.behaving_as_type.one_author_birthplace_uuid_json = text

    stored = item.behaving_as_type.one_author_birthplace_uuid
    assert_instance_of(Hash, stored)
    assert_equal(JSON.parse(text), stored)
  end

  test "doesn't store JSON if invalid" do
    text = '{"type":"Point","coordinates":[-48.23456,20.12345}'
    item = Item.new(:item_type => item_types(:one_author))
    item.behaving_as_type.one_author_birthplace_uuid_json = text

    stored = item.behaving_as_type.one_author_birthplace_uuid
    assert_nil(stored)
  end

  test "retains user input when invalid" do
    text = '{"type":"Point","coordinates":[-48.23456,20.12345}'
    item = Item.new(:item_type => item_types(:one_author))
    item.behaving_as_type.one_author_birthplace_uuid_json = text

    input = item.behaving_as_type.one_author_birthplace_uuid_json
    assert_equal(text, input)
  end
end
