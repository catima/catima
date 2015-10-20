require "test_helper"

class Field::IntTest < ActiveSupport::TestCase
  should validate_numericality_of(:maximum).only_integer.allow_nil
  should validate_numericality_of(:minimum).only_integer.allow_nil
  should validate_numericality_of(:default_value).only_integer.allow_nil

  test "default_value is validated against minimum and maximum" do
    int_field = fields(:one_author_age)
    int_field.minimum = 0
    int_field.maximum = 150

    int_field.default_value = 201
    refute(int_field.valid?)

    int_field.default_value = -1
    refute(int_field.valid?)

    int_field.default_value = 29
    assert(int_field.valid?)
  end
end
