require "test_helper"

class ItemList::SimpleSearchResultTest < ActiveSupport::TestCase
  setup do
    Item.reindex
  end

  test "finds nothing if query is blank" do
    simple = simple_search(catalogs(:search), searches(:blank))
    assert_empty(simple.items.to_a)
  end

  test "counts results by item type" do
    simple = simple_search(catalogs(:search), searches(:toyota))
    counts = simple.item_counts_by_type.to_a

    assert_equal(1, counts.size)

    item_type, count = counts.first
    assert_equal(item_types(:search_vehicle).id, item_type.id)
    assert_equal(4, count)
  end

  test "items is scoped to catalog" do
    simple = simple_search(catalogs(:one), searches(:toyota))
    assert_empty(simple.items.to_a)
  end

  test "only shows public items" do
    simple = simple_search(catalogs(:reviewed), searches(:book))

    results = simple.items.to_a
    assert_includes(results, items(:reviewed_book_finders_keepers_approved))
    refute_includes(results, items(:reviewed_book_end_of_watch))
  end

  private

  def simple_search(catalog, search)
    ItemList::SimpleSearchResult.new(
      :catalog => catalog,
      :query => search.related_search.query,
      :search_uuid => search.uuid
    )
  end
end
