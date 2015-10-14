require "test_helper"

class Field::TextTest < ActiveSupport::TestCase
  should validate_numericality_of(:maximum)
    .only_integer.is_greater_than(0).allow_nil
  should validate_numericality_of(:minimum)
    .only_integer.is_greater_than(0).allow_nil

  test "default_value is validated against minimum and maximum" do
    text_field = fields(:one_title)
    text_field.minimum = 5
    text_field.maximum = 10

    text_field.default_value = "Hello, world!"
    refute(text_field.valid?)

    text_field.default_value = "Hello!"
    assert(text_field.valid?)
  end
end
