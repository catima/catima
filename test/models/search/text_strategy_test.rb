require "test_helper"

class Search::TextStrategyTest < ActiveSupport::TestCase
  test "keywords_for_index" do
    author = items(:one_author_stephen_king)
    field = fields(:one_author_name)
    strategy = Search::TextStrategy.new(field)
    assert_equal("Stephen King", strategy.keywords_for_index(author, :en))
  end

  test "search contains and excludes terms" do
    criteria = { "contains" => "camry", "excludes" => "hybrid" }
    scope = catalogs(:search).items
    field = fields(:search_vehicle_model)
    strategy = Search::TextStrategy.new(field)

    results = strategy.search(scope, criteria)
    assert_includes(results.to_a, items(:search_vehicle_toyota_camry))
    refute_includes(results.to_a, items(:search_vehicle_toyota_camry_hybrid))
  end

  test "search exact" do
    criteria = { "exact" => "camry hybrid" }
    scope = catalogs(:search).items
    field = fields(:search_vehicle_model)
    strategy = Search::TextStrategy.new(field)

    results = strategy.search(scope, criteria)
    assert_includes(results.to_a, items(:search_vehicle_toyota_camry_hybrid))
    refute_includes(results.to_a, items(:search_vehicle_toyota_camry))
  end

  test "search multiple terms" do
    criteria = { "contains" => "hybrid camry" }
    scope = catalogs(:search).items
    field = fields(:search_vehicle_model)
    strategy = Search::TextStrategy.new(field)

    results = strategy.search(scope, criteria)
    assert_includes(results.to_a, items(:search_vehicle_toyota_camry_hybrid))
    refute_includes(results.to_a, items(:search_vehicle_toyota_camry))
  end

  test "search obeys scope" do
    criteria = { "exact" => "camry hybrid" }
    scope = Item.none
    field = fields(:search_vehicle_model)
    strategy = Search::TextStrategy.new(field)

    results = strategy.search(scope, criteria)
    assert_empty(results.to_a)
  end
end
