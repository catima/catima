require "test_helper"

class Field::URLPresenterTest < ActionView::TestCase
  test "#value" do
    author = items(:one_author_stephen_king)
    site_field = Field.find ActiveRecord::FixtureSet.identify('one_author_site')
    presenter = Field::URLPresenter.new(self, author, site_field)
    assert_equal(
      '<a target="_blank" rel="noopener"'\
      'href="http://stephenking.com/index.html">'\
      "stephenking.com/index.html"\
      "</a>",
      presenter.value)
  end
end
