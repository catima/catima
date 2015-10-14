require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  test "#index? allows only admins" do
    assert(policy(users(:system_admin)).index?)
    assert(policy(users(:one_admin)).index?)
    refute(policy(users(:two)).index?)
    refute(policy(Guest.new).index?)
  end

  test "#show? allows only admins" do
    record = users(:one)
    assert(policy(users(:system_admin), record).show?)
    assert(policy(users(:one_admin), record).show?)
    refute(policy(users(:two), record).show?)
    refute(policy(Guest.new, record).show?)
  end

  test "#edit? allows only admins" do
    record = users(:one)
    assert(policy(users(:system_admin), record).edit?)
    assert(policy(users(:one_admin), record).edit?)
    refute(policy(users(:two), record).edit?)
    refute(policy(Guest.new, record).edit?)
  end

  test "#update? allows only admins" do
    record = users(:one)
    assert(policy(users(:system_admin), record).update?)
    assert(policy(users(:one_admin), record).update?)
    refute(policy(users(:two), record).update?)
    refute(policy(Guest.new, record).update?)
  end

  test "#destroy allows only system admins" do
    record = users(:one)
    assert(policy(users(:system_admin), record).destroy?)
    refute(policy(users(:one_admin), record).destroy?)
    refute(policy(users(:two), record).destroy?)
    refute(policy(Guest.new, record).destroy?)
  end

  test "Scope shows all for admins, none for others" do
    assert_equal(User.all.to_a, policy_scoped_records(users(:system_admin)))
    assert_equal(User.all.to_a, policy_scoped_records(users(:one_admin)))
    assert_empty(policy_scoped_records(users(:two)))
    assert_empty(policy_scoped_records(Guest.new))
  end

  test "#permit allows email for system admins only" do
    user = users(:one)
    params = params_to_grant("admin", user)

    refute_nil(permit(:system_admin, user, params)[:email])
    assert_nil(permit(:one_admin, user, params)[:email])
  end

  test "#permit prevents granting admin role unless sys admin" do
    user = users(:one)
    params = params_to_grant("admin", user)

    assert_empty(
      permit(:one_admin, user, params)[:catalog_permissions_attributes]
    )
    assert_equal(
      params[:user][:catalog_permissions_attributes],
      permit(:system_admin, user, params)[:catalog_permissions_attributes]
    )
  end

  test "#permit prevents catalog admin from granting role in non-administered catalog" do
    user = users(:two)
    params = params_to_grant("editor", user)

    assert_empty(
      permit(:one_admin, user, params)[:catalog_permissions_attributes]
    )
  end

  private

  def policy(user, record=nil)
    UserPolicy.new(user, record)
  end

  def policy_scoped_records(user)
    UserPolicy::Scope.new(user, User).resolve.to_a
  end

  def permit(user_fixture, record, params)
    policy(users(user_fixture), record).permit(params[:user])
  end

  def params_to_grant(role, user)
    perm = user.catalog_permissions.first

    ActionController::Parameters.new(
      :user => {
        :email => "changing-email@example.com",
        :catalog_permissions_attributes => {
          "0" => {
            :id => perm.id,
            :catalog_id => perm.catalog_id,
            :role => role
          }
        }
      })
  end
end
