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

    assert_match('name="item[one_author_born_uuid_time(1i)]" value="1947"', html)
    assert_match('name="item[one_author_born_uuid_time(2i)]" value="9"', html)
    assert_match('name="item[one_author_born_uuid_time(3i)]" value="21"', html)
    assert_match('select id="item_one_author_born_uuid_time_4i"', html)
    assert_match('select id="item_one_author_born_uuid_time_5i"', html)
    assert_match('select id="item_one_author_born_uuid_time_6i"', html)
  end
end
