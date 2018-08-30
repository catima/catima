require "test_helper"

class Field::BooleanPresenterTest < ActionView::TestCase
  include ItemsHelper

  test "#value" do
    boolean_field = Field.find ActiveRecord::FixtureSet.identify('one_author_deceased')

    author = items(:one_author_very_old)
    presenter = Field::BooleanPresenter.new(self, author, boolean_field)
    assert_equal('Yes',
                 presenter.value
                )

    author = items(:one_author_very_young)
    presenter = Field::BooleanPresenter.new(self, author, boolean_field)
    assert_equal('No',
                 presenter.value
                )
  end
end
