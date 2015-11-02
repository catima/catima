require "test_helper"
require_dependency("models/field/file_test")

class Field::ImageTest < Field::FileTest
  test "defaults to image file types" do
    field = Field::Image.new
    assert_equal("jpg, jpeg, png, gif", field.types)
  end
end
