require "test_helper"

class Search::TextStrategyTest < ActiveSupport::TestCase
  test "keywords_for_index" do
    author = items(:one_author_stephen_king)
    field = fields(:one_author_name)
    strategy = Search::TextStrategy.new(author, field, :en)
    assert_equal("Stephen King", strategy.keywords_for_index)
  end
end
