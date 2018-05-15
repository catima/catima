require 'test_helper'

class FavoriteTest < ActiveSupport::TestCase
  should validate_presence_of(:user)
  should validate_presence_of(:item)
end
