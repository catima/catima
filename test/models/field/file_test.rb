require "test_helper"
require_relative "../../../app/models/field/file.rb"

class Field::FileTest < ActiveSupport::TestCase
  should validate_presence_of(:types)

  test "translates specified types into extensions" do
    types_formats = [
      "jpg pdf",
      ".jpg .pdf",
      "jpg, pdf",
      ".jpg, .pdf",
      ".jpg, , .pdf",
    ]
    types_formats.each do |input|
      file_field = Field::File.new(:types => input)
      assert_equal(%w(jpg pdf), file_field.allowed_extensions)
    end
  end
end
