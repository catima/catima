require "test_helper"

class Search::TextStrategyTest < ActiveSupport::TestCase
  test "#keywords_for_index is empty" do
    author = items(:one_author_stephen_king)
    field = fields(:one_author_born)
    strategy = Search::DateTimeStrategy.new(field, :en)
    assert_equal(strategy.keywords_for_index(author), [21, 9, 1947])
  end

  test "search finds item within range" do
    criteria = {
      "before(1i)" => "2015",
      "before(2i)" => "12",
      "before(3i)" => "31",
      "after(1i)" => "1900",
      "after(2i)" => "1",
      "after(3i)" => "1"
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
      "before(1i)" => "2015",
      "before(2i)" => "12",
      "before(3i)" => "31",
      "after(1i)" => "2000",
      "after(2i)" => "1",
      "after(3i)" => "1"
    }.with_indifferent_access

    scope = catalogs(:one).items
    field = fields(:one_author_born)
    strategy = Search::DateTimeStrategy.new(field, :en)

    results = strategy.search(scope, criteria)
    refute_includes(results.to_a, items(:one_author_stephen_king))
    refute_includes(results.to_a, items(:one_author_very_old))
  end
end
