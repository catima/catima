require "test_helper"

class Field::DecimalTest < ActiveSupport::TestCase
  should validate_numericality_of(:maximum).allow_nil
  should validate_numericality_of(:minimum).allow_nil
  should validate_numericality_of(:default_value).allow_nil

  test "default_value is validated against minimum and maximum" do
    decimal_field = fields(:one_author_rank)
    decimal_field.minimum = 0
    decimal_field.maximum = 1

    decimal_field.default_value = "2"
    refute(decimal_field.valid?)

    decimal_field.default_value = "0.25"
    assert(decimal_field.valid?)
  end
end
