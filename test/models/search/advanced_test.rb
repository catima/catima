require "test_helper"

class Search::AdvancedTest < ActiveSupport::TestCase
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
    search = Search::Advanced.new(:model => model)

    results = search.items
    assert_includes(results.to_a, items(:search_vehicle_toyota_highlander))
    assert_includes(results.to_a, items(:search_vehicle_toyota_prius))
    refute_includes(results.to_a, items(:search_vehicle_toyota_camry_hybrid))
    refute_includes(results.to_a, items(:search_vehicle_toyota_camry))
  end
end
