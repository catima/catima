require "test_helper"

class Field::DateTimePresenterTest < ActionView::TestCase
  include JsonHelper
  include BootstrapForm::Helper
  # include React::Rails::ViewHelper

  test "#value" do
    author = items(:one_author_stephen_king)
    born_field = Field.find ActiveRecord::FixtureSet.identify('one_author_born')
    presenter = Field::DateTimePresenter.new(self, author, born_field)

    assert_equal("21 September, 1947", presenter.value)
  end

  test "#value honors locale" do
    author = items(:one_author_stephen_king)
    born_field = Field.find ActiveRecord::FixtureSet.identify('one_author_born')
    presenter = Field::DateTimePresenter.new(self, author, born_field)

    I18n.with_locale(:de) do
      assert_equal("21. September 1947", presenter.value)
    end
    I18n.with_locale(:fr) do
      assert_equal("21 septembre 1947", presenter.value)
    end
    I18n.with_locale(:it) do
      assert_equal("21 settembre 1947", presenter.value)
    end
  end
end
