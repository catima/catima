require "test_helper"

class Field::IntPresenterTest < ActionView::TestCase
  test "#value" do
    author = items(:one_author_stephen_king)
    age_field = Field.find ActiveRecord::FixtureSet.identify('one_author_age')
    presenter = Field::IntPresenter.new(self, author, age_field)
    assert_equal("68", presenter.value)

    author = items(:one_author_very_old)
    presenter = Field::IntPresenter.new(self, author, age_field)
    assert_equal("2,456", presenter.value)
  end
end
