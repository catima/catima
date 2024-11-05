require "test_helper"

class FieldSetsHelperTest < ActionView::TestCase
  include FieldSetsHelper

  test "field_set_type_choices_has_reference_key" do
    category = categories(:one)
    type_choices_for_category = field_set_type_choices(category)
    assert_not_includes type_choices_for_category.map(&:first), 'reference', "Category should not include 'reference' type"

    author = item_types(:one_author)
    type_choices_for_author = field_set_type_choices(author)
    assert_includes type_choices_for_author.map(&:first), 'reference', "Author should include 'reference' type"
  end
end
