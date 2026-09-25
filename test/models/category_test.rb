require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:name)

  test "soft_delete! marks the category as deleted and unlinks linked choices" do
    category = categories(:language)
    choice = choices(:one_with_category)
    assert_equal category.id, choice.category_id

    category.soft_delete!

    refute category.reload.not_deleted?
    assert_nil choice.reload.category_id
  end

  test "destroy unlinks linked choices" do
    category = categories(:language)
    choice = choices(:one_with_category)

    category.destroy

    assert_nil choice.reload.category_id
    assert_equal 0, Choice.where(category_id: category.id).count
  end
end
