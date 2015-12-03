require "test_helper"

class Field::XrefTest < ActiveSupport::TestCase
  should validate_presence_of(:xref)
  should_not allow_value("not a URL").for(:xref)

  test "checks that xref is a valid service" do
    field = Field::Xref.new(
      :slug => "xref",
      :item_type => item_types(:one),
      :name_en => "test",
      :name_plural_en => "tests"
    )

    field.xref = "https://api.github.com/repos/rails/rails"
    refute(field.valid?)

    field.xref = "http://vss.naxio.ch/keywords/default/api/v1"
    assert(field.valid?)
  end
end
