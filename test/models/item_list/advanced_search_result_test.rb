require "test_helper"

class ItemList::AdvancedSearchResultTest < ActiveSupport::TestCase
  test "search multiple fields" do
    criteria = {
      "search_vehicle_make_uuid" => { "exact" => "toyota" },
      "search_vehicle_model_uuid" => { "excludes" => "camry" }
    }
    model = AdvancedSearch.new(
      :catalog => catalogs(:search),
      :item_type => item_types(:search_vehicle),
      :criteria => criteria
    )
    search = ItemList::AdvancedSearchResult.new(:model => model)

    results = search.items
    assert_includes(results.to_a, items(:search_vehicle_toyota_highlander))
    assert_includes(results.to_a, items(:search_vehicle_toyota_prius))
    refute_includes(results.to_a, items(:search_vehicle_toyota_camry_hybrid))
    refute_includes(results.to_a, items(:search_vehicle_toyota_camry))
  end

  test "only shows public items" do
    model = AdvancedSearch.new(
      :catalog => catalogs(:reviewed),
      :item_type => item_types(:reviewed_book),
      :criteria => {}
    )
    search = ItemList::AdvancedSearchResult.new(:model => model)

    results = search.items.to_a
    assert_includes(results, items(:reviewed_book_finders_keepers_approved))
    refute_includes(results, items(:reviewed_book_end_of_watch))
  end
end
