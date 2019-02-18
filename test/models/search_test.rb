require 'test_helper'

class SearchTest < ActiveSupport::TestCase
  should validate_presence_of(:user)
  should validate_presence_of(:related_search)
end
