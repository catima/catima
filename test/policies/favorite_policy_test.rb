require "test_helper"

class FavoritePolicyTest < ActiveSupport::TestCase
  test "#destroy? allows authenticated users" do
    refute(policy(Guest.new, favorites(:one)).destroy?)
    refute(policy(users(:one), favorites(:one)).destroy?)
    refute(policy(users(:one_admin), favorites(:four)).destroy?)
    assert(policy(users(:one_admin), favorites(:one)).destroy?)
    assert(policy(users(:one_editor), favorites(:two)).destroy?)
  end

  test "#create? authenticated users" do
    refute(policy(Guest.new, favorites(:one)).create?)
  end

  test "#create? for private catalog for users with at least editor role" do
    refute(policy(users(:one), favorites(:three)).create?)
    assert(policy(users(:one_editor), favorites(:two)).create?)
  end

  def policy(user, favorite=favorites(:one))
    FavoritePolicy.new(user, favorite)
  end
end
