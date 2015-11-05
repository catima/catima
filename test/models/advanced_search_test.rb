require "test_helper"

class AdvancedSearchTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:item_type)
end
