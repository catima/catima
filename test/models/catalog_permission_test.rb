require "test_helper"

class CatalogPermissionTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:user)
  should validate_presence_of(:role)
  should validate_inclusion_of(:role).in_array(%w(user editor reviewer admin))

  test "#role_at_least?" do
    user = CatalogPermission.new(:role => "user")
    assert(user.role_at_least?("user"))
    refute(user.role_at_least?("editor"))
    refute(user.role_at_least?("reviewer"))
    refute(user.role_at_least?("admin"))
    refute(user.role_at_least?("unknown"))

    user = CatalogPermission.new(:role => "editor")
    assert(user.role_at_least?("user"))
    assert(user.role_at_least?("editor"))
    refute(user.role_at_least?("reviewer"))
    refute(user.role_at_least?("admin"))
    refute(user.role_at_least?("unknown"))

    user = CatalogPermission.new(:role => "reviewer")
    assert(user.role_at_least?("user"))
    assert(user.role_at_least?("editor"))
    assert(user.role_at_least?("reviewer"))
    refute(user.role_at_least?("admin"))
    refute(user.role_at_least?("unknown"))

    user = CatalogPermission.new(:role => "admin")
    assert(user.role_at_least?("user"))
    assert(user.role_at_least?("editor"))
    assert(user.role_at_least?("reviewer"))
    assert(user.role_at_least?("admin"))
    refute(user.role_at_least?("unknown"))
  end
end
