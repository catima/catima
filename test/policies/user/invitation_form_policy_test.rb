require "test_helper"

class User::InvitationFormPolicyTest < ActiveSupport::TestCase
  test "#new? allows system admins or catalog admins" do
    record = users(:one)
    assert(policy(users(:system_admin), record).new?)
    assert(policy(users(:one_admin), record).new?)
    refute(policy(users(:two), record).new?)
    refute(policy(Guest.new, record).new?)
  end

  test "#create? allows system admins or catalog admins" do
    record = users(:one)
    assert(policy(users(:system_admin), record).create?)
    assert(policy(users(:one_admin), record).create?)
    refute(policy(users(:two), record).create?)
    refute(policy(Guest.new, record).create?)
  end

  test "#permit prevents granting admin role" do
    params = params("admin")
    assert_empty(
      permit(:one_admin, params)[:catalog_permissions_attributes]
    )
  end

  test "#permit allows granting editor role" do
    params = params("editor")
    refute_empty(
      permit(:one_admin, params)[:catalog_permissions_attributes]
    )
  end

  private

  def policy(user, record=nil)
    User::InvitationFormPolicy.new(user, record)
  end

  def permit(user_fixture, params)
    policy(users(user_fixture)).permit(params[:user])
  end

  def params(role)
    ActionController::Parameters.new(
      :user => {
        :catalog_permissions_attributes => {
          "0" => {
            :catalog_id => "1",
            :role => role
          }
        }
      })
  end
end
