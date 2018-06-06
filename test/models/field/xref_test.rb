require "test_helper"

class Field::XrefTest < ActiveSupport::TestCase
  include WithVCR

  should validate_presence_of(:xref)
  should_not allow_value("not a URL").for(:xref)

  unless ENV['TRAVIS']
    test "checks that xref is a valid service" do
      field = Field::Xref.new(
        :slug => "xref",
        :field_set => item_types(:one),
        :name_en => "test",
        :name_plural_en => "tests"
      )

      with_expiring_vcr_cassette do
        #field.xref = "https://api.github.com/repos/rails/rails"
        #refute(field.valid?)

        field.xref = "https://catima-xref.herokuapp.com/api/v1"
        assert(field.valid?)
      end
    end
  end
end
