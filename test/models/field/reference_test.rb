require "test_helper"

class Field::ReferenceTest < ActiveSupport::TestCase
  should validate_presence_of(:related_item_type)

  test "doesn't allow related item type from different catalog" do
    ref_type = fields(:one_author_collaborator)
    assert(ref_type.valid?)

    ref_type.related_item_type = item_types(:two_author)
    refute(ref_type.valid?)
  end
end
