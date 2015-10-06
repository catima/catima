require "test_helper"

class GuestTest < ActiveSupport::TestCase
  test "#authenticated?" do
    refute(Guest.new.authenticated?)
  end

  test "#system_admin?" do
    refute(Guest.new.system_admin?)
  end

  test "#admin_of_any_catalog?" do
    refute(Guest.new.admin_of_any_catalog?)
  end

  test "#catalog_role_at_least?" do
    refute(Guest.new.catalog_role_at_least?(catalogs(:one), "user"))
  end
end
