require "test_helper"

class CSVImportPolicyTest < ActiveSupport::TestCase
  test "#new? allows editors and system admins" do
    refute(policy(users(:one), item_types(:one_author)).new?)
    refute(policy(users(:two_editor), item_types(:one_author)).new?)
    assert(policy(users(:two_editor), item_types(:two_author)).new?)
    assert(policy(users(:system_admin), item_types(:two_author)).new?)
  end

  test "#create? allows editors and system admins" do
    refute(policy(users(:one), item_types(:one_author)).create?)
    refute(policy(users(:two_editor), item_types(:one_author)).create?)
    assert(policy(users(:two_editor), item_types(:two_author)).create?)
    assert(policy(users(:system_admin), item_types(:two_author)).create?)
  end

  private

  def policy(user, item_type)
    import = CSVImport.new(:item_type => item_type)
    CSVImportPolicy.new(user, import)
  end
end
