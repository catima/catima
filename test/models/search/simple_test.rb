require "test_helper"

class Search::SimpleTest < ActiveSupport::TestCase
  setup do
    Item.reindex
  end

  test "finds nothing if query is blank" do
    simple = simple_search(catalogs(:search), " ")
    assert_empty(simple.items.to_a)
  end

  test "counts results by item type" do
    simple = simple_search(catalogs(:search), "toyota")
    counts = simple.item_counts_by_type.to_a

    assert_equal(1, counts.size)

    item_type, count = counts.first
    assert_equal(item_types(:search_vehicle).id, item_type.id)
    assert_equal(3, count)
  end

  test "items is scoped to catalog" do
    simple = simple_search(catalogs(:one), "toyota")
    assert_empty(simple.items.to_a)
  end

  private

  def simple_search(catalog, query)
    Search::Simple.new(:catalog => catalog, :query => query)
  end
end
