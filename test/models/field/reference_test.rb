require "test_helper"

class Field::ReferenceTest < ActiveSupport::TestCase
  should validate_presence_of(:related_item_type)

  test "doesn't allow related item type from different catalog" do
    ref_type = fields(:one_author_collaborator)
    assert(ref_type.valid?)

    ref_type.related_item_type = item_types(:two_author)
    refute(ref_type.valid?)
  end

  test "required multivalued choice set field validates presence of value" do
    item = Item.new(
      :creator => users(:one_editor),
      :catalog => catalogs(:one),
      :item_type => item_types(:one_with_required_reference)
    ).behaving_as_type

    ref = items(:one_author_stephen_king)

    refute(item.valid?)
    item.public_send(:required_reference=, [""])
    refute(item.valid?)
    item.public_send(:required_reference=, ["", ref.id.to_s])
    assert(item.valid?)
  end

  test "persists multiple choices" do
    item = Item.new(
      :creator => users(:one_editor),
      :catalog => catalogs(:one),
      :item_type => item_types(:one_with_required_reference)
    ).behaving_as_type

    ref_ids = [
      items(:one_author_stephen_king),
      items(:one_author_very_old)
    ].map { |i| i.id.to_s }

    item.public_send(:required_reference=, ["", *ref_ids])
    item.save!

    assert_equal(ref_ids, item.reload.data["required_reference"])
  end
end
