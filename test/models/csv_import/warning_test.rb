require "test_helper"

class CSVImport::WarningTest < ActiveSupport::TestCase
  test "creates warning with row, column, message, and line_number" do
    warning = CSVImport::Warning.new(
      { "name" => "John" },
      "category",
      "Multiple choices found",
      { choice_count: 2 },
      5
    )

    assert_equal({ "name" => "John" }, warning.row)
    assert_equal("category", warning.column)
    assert_equal("Multiple choices found", warning.message)
    assert_equal({ choice_count: 2 }, warning.details)
    assert_equal(5, warning.line_number)
  end

  test "creates warning without line_number (backwards compatible)" do
    warning = CSVImport::Warning.new(
      { "name" => "John" },
      "category",
      "Multiple choices found",
      { choice_count: 2 }
    )

    assert_nil(warning.line_number)
  end

  test "to_s formats warning message" do
    warning = CSVImport::Warning.new(
      { "name" => "John" },
      "category",
      "Ambiguous choice"
    )

    # Format matching validation errors
    assert_equal "category: Ambiguous choice", warning.to_s
  end
end
