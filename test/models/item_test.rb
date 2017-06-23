require "test_helper"

class ItemTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:creator)
  should validate_presence_of(:item_type)

  test ".with_type returns all items if type is nil" do
    items = Item.with_type(nil)
    assert_equal(Item.all.to_sql, items.to_sql)
  end

  test ".with_type returns items belonging to specified type" do
    type = item_types(:one_book)
    found = Item.with_type(type)

    assert_includes(found, items(:one_book_end_of_watch))
    refute_includes(found, items(:one_author_stephen_king))
  end

  test "#behaving_as_type returns object with field UUID accessors" do
    item = items(:one_book_end_of_watch).behaving_as_type
    %i(one_book_title one_book_author).map(&method(:fields)).each do |field|
      assert(item.respond_to?(field.uuid))
      assert(item.respond_to?("#{field.uuid}="))
    end
  end

  test "#behaving_as_type returns object with json accessors" do
    item = items(:one_book_end_of_watch).behaving_as_type
    %i(one_book_title one_book_author).map(&method(:fields)).each do |field|
      assert(item.respond_to?("#{field.uuid}_json"))
      assert(item.respond_to?("#{field.uuid}_json="))
    end
  end
end
