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
    assert(user.catalog_role_at_least?(catalog, "member"))
    assert(user.catalog_role_at_least?(catalog, "editor"))
    refute(user.catalog_role_at_least?(catalog, "super-editor"))
    refute(user.catalog_role_at_least?(catalog, "reviewer"))
    refute(user.catalog_role_at_least?(catalog, "admin"))

    assert(user.catalog_role_at_least?(catalogs(:one), "user"))
    refute(user.catalog_role_at_least?(catalogs(:one), "member"))
    refute(user.catalog_role_at_least?(catalogs(:one), "editor"))
    refute(user.catalog_role_at_least?(catalogs(:one), "super-editor"))
    refute(user.catalog_role_at_least?(catalogs(:one), "reviewer"))
    refute(user.catalog_role_at_least?(catalogs(:one), "admin"))
  end

  test "#catalog_role" do
    assert_equal("editor", users(:two_editor).catalog_role(catalogs(:two)))
    assert_equal("user", users(:two_editor).catalog_role(catalogs(:one)))
    assert_equal("admin", users(:one_admin).catalog_role(catalogs(:one)))
    assert_equal("user", users(:one_admin).catalog_role(catalogs(:two)))
    assert_equal("super-editor", users(:one_super_editor).catalog_role(catalogs(:one)))
    assert_equal("member", users(:one_member).catalog_role(catalogs(:one)))

    # one_user is member in one group which has super-editor role for catalog one
    assert_equal('super-editor', users(:one_user).catalog_role(catalogs(:one)))

    # user two_admin is admin for catalog two, but member through the group two
    assert_equal('admin', users(:two_admin).catalog_role(catalogs(:two)))
  end

  test "#admin_of_any_catalog?" do
    refute(users(:one).admin_of_any_catalog?)
    assert(users(:one_admin).admin_of_any_catalog?)
  end

  test "#super_editor_of_any_catalog?" do
    refute(users(:one).super_editor_of_any_catalog?)
    assert(users(:one_super_editor).super_editor_of_any_catalog?)
    # User one_user is super-editor through group one
    assert(users(:one_user).super_editor_of_any_catalog?)
  end

  test "#editor_of_any_catalog?" do
    refute(users(:one).editor_of_any_catalog?)
    assert(users(:two_editor).editor_of_any_catalog?)
  end

  test "#member_of_any_catalog?" do
    refute(users(:one).member_of_any_catalog?)
    assert(users(:one_member).member_of_any_catalog?)
  end

  test "#active_for_authentication?" do
    assert(users(:one_user).active_for_authentication?)
    refute(users(:one_user_deleted).active_for_authentication?)
  end

  test "#inactive_message" do
    assert_equal(:inactive, users(:one_user).inactive_message)
    assert_equal(:invalid, users(:one_user_deleted).inactive_message)
  end
end
