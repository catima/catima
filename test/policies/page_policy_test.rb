require "test_helper"

class PagePolicyTest < ActiveSupport::TestCase
  test "#index? allows editors and system admins" do
    refute(policy(users(:one), nil).index?)
    refute(policy(Guest.new, nil).index?)
    assert(policy(users(:two_editor), nil).index?)
    assert(policy(users(:system_admin), nil).index?)
  end

  test "#create? allows editors and system admins" do
    refute(policy(users(:one), pages(:one)).create?)
    refute(policy(users(:two_editor), pages(:one)).create?)
    assert(policy(users(:two_editor), pages(:two)).create?)
    assert(policy(users(:system_admin), pages(:two)).create?)
  end

  test "#new? allows editors and system admins" do
    refute(policy(users(:one), pages(:one)).new?)
    refute(policy(users(:two_editor), pages(:one)).new?)
    assert(policy(users(:two_editor), pages(:two)).new?)
    assert(policy(users(:system_admin), pages(:two)).new?)
  end

  test "#show? allows editors and system admins" do
    refute(policy(users(:one), pages(:one)).show?)
    refute(policy(users(:two_editor), pages(:one)).show?)
    assert(policy(users(:two_editor), pages(:two)).show?)
    assert(policy(users(:system_admin), pages(:two)).show?)
  end

  test "#update? allows reviewers, system admins, and editors of own pages" do
    refute(policy(users(:one), pages(:one)).update?)
    refute(policy(users(:two_editor), pages(:one)).update?)
    refute(policy(users(:two_editor), pages(:two)).update?)
    assert(policy(users(:two_editor), pages(:created_by_two_editor)).update?)
    assert(policy(users(:system_admin), pages(:two)).update?)
  end

  test "#edit? allows reviewers, system admins, and editors of own pages" do
    refute(policy(users(:one), pages(:one)).edit?)
    refute(policy(users(:two_editor), pages(:one)).edit?)
    refute(policy(users(:two_editor), pages(:two)).edit?)
    assert(policy(users(:two_editor), pages(:created_by_two_editor)).edit?)
    assert(policy(users(:system_admin), pages(:two)).edit?)
  end

  test "#destroy? allows reviewers, system admins, and editors of own pages" do
    refute(policy(users(:one), pages(:one)).destroy?)
    refute(policy(users(:two_editor), pages(:one)).destroy?)
    refute(policy(users(:two_editor), pages(:two)).destroy?)
    assert(policy(users(:two_editor), pages(:created_by_two_editor)).destroy?)
    assert(policy(users(:system_admin), pages(:two)).destroy?)
  end

  test "Scope shows all for system admins" do
    assert_equal(Page.all.to_a, policy_scoped_pages(users(:system_admin)))
  end

  test "Scope shows none for plain users and guests" do
    assert_empty(policy_scoped_pages(users(:one)))
    assert_empty(policy_scoped_pages(Guest.new))
  end

  test "Scope shows editor only pages in her catalog" do
    assert_equal(catalogs(:two).pages.to_a, policy_scoped_pages(users(:two_editor)))
  end

  private

  def policy(user, page=pages(:one))
    PagePolicy.new(user, page)
  end

  def policy_scoped_pages(user)
    PagePolicy::Scope.new(user, Page).resolve.to_a
  end
end
