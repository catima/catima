require "test_helper"

class Field::DecimalPresenterTest < ActionView::TestCase
  test "#value" do
    author = items(:one_author_stephen_king)
    rank_field = fields(:one_author_rank)
    presenter = Field::DecimalPresenter.new(self, author, rank_field)
    assert_equal("1.88891", presenter.value)
  end
end
