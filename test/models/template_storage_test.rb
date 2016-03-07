require 'test_helper'

class TemplateStorageTest < ActiveSupport::TestCase
  should validate_presence_of(:body)
  should validate_presence_of(:format)
  should validate_presence_of(:handler)
  should validate_presence_of(:path)
end
