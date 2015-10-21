require "test_helper"

class Field::URLPresenterTest < ActionView::TestCase
  test "#value" do
    author = items(:one_author_stephen_king)
    site_field = fields(:one_author_site)
    presenter = Field::URLPresenter.new(self, author, site_field)
    assert_equal("http://stephenking.com/index.html", presenter.value)
  end
end
