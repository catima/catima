require 'test_helper'

class ContainerTest < ActiveSupport::TestCase
  should validate_presence_of(:page_id)
  should validate_presence_of(:content)
  should validate_presence_of(:locale)
end
