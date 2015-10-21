require "test_helper"

class Field::EmailPresenterTest < ActionView::TestCase
  test "#value" do
    author = items(:one_author_stephen_king)
    email_field = fields(:one_author_email)
    presenter = Field::EmailPresenter.new(self, author, email_field)
    assert_equal("sk@stephenking.com", presenter.value)
  end
end
