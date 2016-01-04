require "test_helper"

class Field::DateTimePresenterTest < ActionView::TestCase
  include BootstrapForm::Helper

  test "#value" do
    author = items(:one_author_stephen_king)
    born_field = fields(:one_author_born)
    presenter = Field::DateTimePresenter.new(self, author, born_field)

    assert_equal("21 September, 1947", presenter.value)
  end

  test "#value honors locale" do
    author = items(:one_author_stephen_king)
    born_field = fields(:one_author_born)
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

  test "#input" do
    author = items(:one_author_stephen_king).behaving_as_type
    born_field = fields(:one_author_born)
    presenter = Field::DateTimePresenter.new(self, author, born_field)

    html = bootstrap_form_for(author, :url => "") do |f|
      presenter.input(f, :one_author_born_uuid)
    end

    assert_match('select id="item_one_author_born_uuid_time_1i"', html)
    assert_match('select id="item_one_author_born_uuid_time_2i"', html)
    assert_match('select id="item_one_author_born_uuid_time_3i"', html)
    assert_match('<option value="1947" selected="selected">', html)
    assert_match('<option value="21" selected="selected">', html)
    assert_match('<option value="9" selected="selected">', html)
  end
end
