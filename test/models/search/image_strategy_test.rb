require "test_helper"

class Search::ImageStrategyTest < ActiveSupport::TestCase
  test "keywords_for_index" do
    author = items(:one_author_with_images)
    field = fields(:one_author_picture)
    strategy = Search::ImageStrategy.new(field, :en)
    assert_equal("One author picture", strategy.keywords_for_index(author))

    field = fields(:one_author_picture_inactive_legend)
    strategy = Search::ImageStrategy.new(field, :en)
    assert_not_equal("One author new picture", strategy.keywords_for_index(author))
  end
end
