require "test_helper"

class Search::TextStrategyTest < ActiveSupport::TestCase
  test "#keywords_for_index is empty" do
    author = items(:one_author_stephen_king)
    field = fields(:one_author_born)
    strategy = Search::DateTimeStrategy.new(field, :en)
    assert_equal(strategy.keywords_for_index(author), [21, 9, 1947])
  end

  test "search finds item with exact month with a field formatted as `M`" do
    criteria = {
      :condition => "exact",
      :field_condition => "and",
      :start => { :exact => { "M" => "6" } },
      :end => { :exact => "" }
    }.with_indifferent_access

    scope = catalogs(:one).items
    field = fields(:one_author_most_active_month)
    strategy = Search::DateTimeStrategy.new(field, :en)

    results = strategy.search(scope, criteria)
    assert_includes(results.to_a, items(:one_author_stephen_king))
    refute_includes(results.to_a, items(:one_author_very_young))
  end

  test "search finds item with hour with a field formatted as `h`" do
    criteria = {
      :condition => "after",
      :field_condition => "and",
      :start => { :after => { "h" => "9" } },
      :end => { :exact => "" }
    }.with_indifferent_access

    scope = catalogs(:one).items
    field = fields(:one_author_most_active_hour)
    strategy = Search::DateTimeStrategy.new(field, :en)

    results = strategy.search(scope, criteria)
    assert_includes(results.to_a, items(:one_author_stephen_king))
    refute_includes(results.to_a, items(:one_author_very_young))
  end

  test "search finds item within range" do
    criteria = {
      :condition => "between",
      :field_condition => "and",
      :start => {
        :exact => {
          "Y": "1900",
          "M": "1",
          "D": "1"
        }
      },
      :end => {
        :exact => {
          "Y": "2015",
          "M": "12",
          "D": "31"
        }
      }
    }.with_indifferent_access

    scope = catalogs(:one).items
    field = fields(:one_author_born)
    strategy = Search::DateTimeStrategy.new(field, :en)

    results = strategy.search(scope, criteria)
    assert_includes(results.to_a, items(:one_author_stephen_king))
    refute_includes(results.to_a, items(:one_author_very_young))
  end

  test "search excludes item outside of range" do
    criteria = {
      :condition => "between",
      :field_condition => "and",
      :start => {
        :exact => {
          "Y": "2015",
          "M": "12",
          "D": "31"
        }
      },
      :end => {
        :exact => {
          "Y": "2000",
          "M": "1",
          "D": "1"
        }
      }
    }.with_indifferent_access

    scope = catalogs(:one).items
    field = fields(:one_author_born)
    strategy = Search::DateTimeStrategy.new(field, :en)

    results = strategy.search(scope, criteria)
    refute_includes(results.to_a, items(:one_author_stephen_king))
    refute_includes(results.to_a, items(:one_author_very_old))
  end
end
