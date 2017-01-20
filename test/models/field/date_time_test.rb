require "test_helper"
require_dependency("field/date_time")

class Field::DateTimeTest < ActiveSupport::TestCase
  should validate_inclusion_of(:format).in_array(%w(Y YM YMD YMDh YMDhm YMDhms))

  test "has default format" do
    field = Field::DateTime.new
    assert_equal("YMD", field.format)
  end

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

  test "stores date with hours, minutes, and seconds" do
    datetime = [2015, 12, 31, 14, 30, 19]
    item = Item.new(:item_type => item_types(:one_author))
    item.behaving_as_type.one_author_birth_time_uuid_time = datetime

    stored = item.behaving_as_type.one_author_birth_time_uuid
    assert_equal(1_451_568_619, stored)
  end

  test "stores years and months only, removing unnecessary precision" do
    datetime = [2015, 12, 31, 14, 30, 19]
    item = Item.new(:item_type => item_types(:one_author))
    item.behaving_as_type.one_author_birth_month_uuid_time = datetime

    stored = item.behaving_as_type.one_author_birth_month_uuid
    assert_equal(1_448_924_400, stored)
  end

  test "stores date components as integer when provided as hash" do
    date = { 2 => 12, 1 => 2015, 3 => 31 }
    item = Item.new(:item_type => item_types(:one_author))
    item.behaving_as_type.one_author_born_uuid_time = date

    stored = item.behaving_as_type.one_author_born_uuid
    assert_equal(1_451_516_400, stored)
  end

  # TODO: Update to JSON datetime format
  # test "retrieves integer as time with zone" do
  #   item = items(:one_author_stephen_king)
  #   time_with_zone = item.behaving_as_type.one_author_born_uuid_time
  #   assert_instance_of(ActiveSupport::TimeWithZone, time_with_zone)
  #   assert_equal("1947-09-21 00:00:00 +0200", time_with_zone.to_s)
  # end
end
