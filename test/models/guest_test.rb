require "test_helper"

class GuestTest < ActiveSupport::TestCase
  test "#authenticated?" do
    refute(Guest.new.authenticated?)
  end

  test "#catalog_role_at_least?" do
    refute(Guest.new.catalog_role_at_least?(catalogs(:one), "user"))
  end
end
