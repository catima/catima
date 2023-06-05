require "test_helper"
require_relative '../../../app/models/field/choice_set'

class Field::ChoiceSetTest < ActiveSupport::TestCase
  should belong_to(:choice_set)

  test "doesn't allow choice set from different catalog" do
    choice_set_field = fields(:one_author_language)
    assert(choice_set_field.valid?)

    choice_set_field.choice_set = choice_sets(:two_languages)
    refute(choice_set_field.valid?)
  end

  test "required multivalued choice set field validates presence of value" do
    item = Item.new(
      :creator => users(:one_editor),
      :updater => users(:one_editor),
      :catalog => catalogs(:one),
      :item_type => item_types(:one_with_required_choice_set)
    ).behaving_as_type

    choice = choices(:one_english)

    refute(item.valid?)
    item.public_send(:required_choice_set=, [""])
    refute(item.valid?)
    item.public_send(:required_choice_set=, ["", choice.id.to_s])
    assert(item.valid?)
  end

  test "persists multiple choices" do
    item = Item.new(
      :creator => users(:one_editor),
      :updater => users(:one_editor),
      :catalog => catalogs(:one),
      :item_type => item_types(:one_with_required_choice_set)
    ).behaving_as_type

    choice_ids = [choices(:one_english).id.to_s, choices(:one_spanish).id.to_s]

    item.public_send(:required_choice_set=, ["", *choice_ids])
    item.save!

    assert_equal(choice_ids, item.reload.data["required_choice_set"])
  end

  test "a category cannot be used twice in a field belonging the same item type" do
    set = choice_sets(:one_category)

    it = item_types(:one)
    field_valid = Field::ChoiceSet.new(
      :field_set => it,
      :slug => "without-existing-category",
      :name_en => "Without existing category",
      :name_plural_en => "Without existing categories",
      :choice_set => set
    )

    assert(field_valid.valid?)

    it = item_types(:one_author)
    field_invalid = Field::ChoiceSet.new(
      :field_set => it,
      :slug => "with-existing-category",
      :name_en => "With existing category",
      :name_plural_en => "With existing categories",
      :choice_set => set
    )

    refute(field_invalid.valid?)
  end
end
