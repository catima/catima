require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_presence_of(:owner)
  should validate_presence_of(:catalog)

  test "catalog role without permissions is always a user" do
    group = groups(:one)
    assert_equal(0, group.catalog_permissions.where(catalog: catalogs(:two)).count)
    assert_equal('user', group.role_for_catalog(catalogs(:two)))
  end
end
