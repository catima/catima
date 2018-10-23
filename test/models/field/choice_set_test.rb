require "test_helper"
require_relative "../../../app/models/field/choice_set.rb"

class Field::ChoiceSetTest < ActiveSupport::TestCase
  should validate_presence_of(:choice_set)

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
end
