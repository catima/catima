require "test_helper"

class Search::URLStrategyTest < ActiveSupport::TestCase
  test "search i18n field" do
    criteria = { "exact" => "https://www.google.fr/" }.with_indifferent_access
    scope = catalogs(:multilingual).items
    field = fields(:multilingual_author_site)

    en_strategy = Search::URLStrategy.new(field, :en)
    fr_strategy = Search::URLStrategy.new(field, :fr)

    assert_empty(en_strategy.search(scope, criteria))

    fr_results = fr_strategy.search(scope, criteria)
    assert_includes(fr_results.to_a, items(:multilingual_author_example))
  end
end
