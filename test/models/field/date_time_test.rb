require "test_helper"
require_dependency("field/date_time")

class Field::DateTimeTest < ActiveSupport::TestCase
  test "stores date components as integer" do
    date = [2015, 12, 31]
    item = Item.new(:item_type => item_types(:one_author))
    item.behaving_as_type.one_author_born_uuid_time = date

    stored = item.behaving_as_type.one_author_born_uuid
    assert_equal(1_451_516_400, stored)
  end

  test "stores nil" do
    item = Item.new(:item_type => item_types(:one_author))
    item.behaving_as_type.one_author_born_uuid_time = nil

    stored = item.behaving_as_type.one_author_born_uuid
    assert_nil(stored)
  end

  test "stores date components as integer when provided as hash" do
    date = { 2 => 12, 1 => 2015, 3 => 31 }
    item = Item.new(:item_type => item_types(:one_author))
    item.behaving_as_type.one_author_born_uuid_time = date

    stored = item.behaving_as_type.one_author_born_uuid
    assert_equal(1_451_516_400, stored)
  end

  test "retrieves integer as time with zone" do
    item = items(:one_author_stephen_king)
    time_with_zone = item.behaving_as_type.one_author_born_uuid_time
    assert_instance_of(ActiveSupport::TimeWithZone, time_with_zone)
    assert_equal("1947-09-21 00:00:00 +0200", time_with_zone.to_s)
  end
end
