require "test_helper"

class Search::TextStrategyTest < ActiveSupport::TestCase
  test "#keywords_for_index is nil" do
    author = items(:one_author_stephen_king)
    field = fields(:one_author_born)
    strategy = Search::DateTimeStrategy.new(field, :en)
    assert_nil(strategy.keywords_for_index(author))
  end

  test "search finds item within range" do
    criteria = {
      "before" => { 1 => 2015, 2 => 12, 3 => 31 },
      "after" => { 1 => 1900, 2 => 1, 3 => 1 }
    }.with_indifferent_access

    scope = catalogs(:one).items
    field = fields(:one_author_born)
    strategy = Search::DateTimeStrategy.new(field, :en)

    results = strategy.search(scope, criteria)
    assert_includes(results.to_a, items(:one_author_stephen_king))
    refute_includes(results.to_a, items(:one_author_very_old))
  end

  test "search excludes item outside of range" do
    criteria = {
      "before" => { 1 => 2015, 2 => 12, 3 => 31 },
      "after" => { 1 => 2000, 2 => 1, 3 => 1 }
    }.with_indifferent_access

    scope = catalogs(:one).items
    field = fields(:one_author_born)
    strategy = Search::DateTimeStrategy.new(field, :en)

    results = strategy.search(scope, criteria)
    refute_includes(results.to_a, items(:one_author_stephen_king))
    refute_includes(results.to_a, items(:one_author_very_old))
  end
end
