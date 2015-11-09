require "test_helper"

class PageTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:content)
  should validate_presence_of(:locale)
  should validate_presence_of(:slug)
  should validate_presence_of(:title)
end
