require "test_helper"

class Field::DateTimePresenterTest < ActionView::TestCase
  include BootstrapForm::Helper

  test "#value" do
    author = items(:one_author_stephen_king)
    born_field = fields(:one_author_born)
    presenter = Field::DateTimePresenter.new(self, author, born_field)

    assert_equal("21 September, 1947 00:00", presenter.value)
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
    assert_match('select id="item_one_author_born_uuid_time_4i"', html)
    assert_match('select id="item_one_author_born_uuid_time_5i"', html)
    assert_match('select id="item_one_author_born_uuid_time_6i"', html)
    assert_match('<option value="1947" selected="selected">', html)
    assert_match('<option value="21" selected="selected">', html)
    assert_match('<option value="9" selected="selected">', html)
  end
end
