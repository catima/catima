require "test_helper"

class Field::TextPresenterTest < ActionView::TestCase
  test "#value" do
    author = items(:one_author_stephen_king)
    name_field = fields(:one_author_name)
    presenter = Field::TextPresenter.new(self, author, name_field)
    assert_equal("Stephen King", presenter.value)
  end
end
