require "test_helper"

class UserTest < ActiveSupport::TestCase
  should validate_presence_of(:primary_language)
  should validate_inclusion_of(:primary_language).in_array(%w(de en fr it))

  test "#authenticated?" do
    assert(User.new.authenticated?)
  end

  test "#catalog_role_at_least?" do
    user = users(:two_editor)
    catalog = catalogs(:two)

    assert(user.catalog_role_at_least?(catalog, "user"))
    assert(user.catalog_role_at_least?(catalog, "editor"))
    refute(user.catalog_role_at_least?(catalog, "reviewer"))
    refute(user.catalog_role_at_least?(catalog, "admin"))

    assert(user.catalog_role_at_least?(catalogs(:one), "user"))
    refute(user.catalog_role_at_least?(catalogs(:one), "editor"))
  end

  test "#catalog_role" do
    assert_equal("editor", users(:two_editor).catalog_role(catalogs(:two)))
    assert_equal("user", users(:two_editor).catalog_role(catalogs(:one)))
    assert_equal("admin", users(:one_admin).catalog_role(catalogs(:one)))
    assert_equal("user", users(:one_admin).catalog_role(catalogs(:two)))
  end

  test "#admin_of_any_catalog?" do
    refute(users(:one).admin_of_any_catalog?)
    assert(users(:one_admin).admin_of_any_catalog?)
  end

  test "#editor_of_any_catalog?" do
    refute(users(:one).editor_of_any_catalog?)
    assert(users(:two_editor).editor_of_any_catalog?)
  end
end
