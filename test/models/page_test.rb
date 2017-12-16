require "test_helper"

class PageTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:slug)
  should validate_presence_of(:title)

  should validate_uniqueness_of(:slug).scoped_to(:catalog_id)
end
