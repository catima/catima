require "test_helper"

class Search::SimpleTest < ActiveSupport::TestCase
  setup do
    Item.reindex
  end

  test "finds nothing if query is blank" do
    simple = Search::Simple.new(catalogs(:search), " ")
    assert_empty(simple.items.to_a)
  end

  test "groups results by item type" do
    simple = Search::Simple.new(catalogs(:search), "toyota")
    grouped = simple.items_grouped_by_type.to_a

    assert_equal(1, grouped.size)

    item_type, items = grouped.first
    assert_equal(item_types(:search_vehicle).id, item_type.id)
    assert_includes(items.map(&:id), items(:search_vehicle_toyota_prius).id)
  end

  test "items_grouped_by_type is scoped to catalog" do
    simple = Search::Simple.new(catalogs(:one), "toyota")
    assert_empty(simple.items_grouped_by_type.to_a)
  end
end
