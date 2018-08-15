require "test_helper"

class Field::FilePresenterTest < ActionView::TestCase
  test "#value" do
    author = items(:one_author_stephen_king)
    bio_field = fields(:one_author_bio)
    presenter = Field::FilePresenter.new(self, author, bio_field)
    assert_match("bio.doc</a>, 192 KB", presenter.value)
  end
end
