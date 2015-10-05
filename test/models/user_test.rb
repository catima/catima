require "test_helper"

class UserTest < ActiveSupport::TestCase
  should validate_presence_of(:primary_language)
  should validate_inclusion_of(:primary_language).in_array(%w(de en fr it))

  test "#authenticated?" do
    assert(User.new.authenticated?)
  end

  test "#catalog_role_at_least?" do
    user = users(:two)
    catalog = catalogs(:two)

    assert(user.catalog_role_at_least?(catalog, "user"))
    assert(user.catalog_role_at_least?(catalog, "editor"))
    refute(user.catalog_role_at_least?(catalog, "reviewer"))
    refute(user.catalog_role_at_least?(catalog, "admin"))

    assert(user.catalog_role_at_least?(catalogs(:one), "user"))
    refute(user.catalog_role_at_least?(catalogs(:one), "editor"))
  end
end
