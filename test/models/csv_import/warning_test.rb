require "test_helper"

class CSVImport::WarningTest < ActiveSupport::TestCase
  test "creates warning with row, column, and message" do
    warning = CSVImport::Warning.new(
      { "name" => "John" },
      "category",
      "Multiple choices found",
      { choice_count: 2 }
    )

    assert_equal({ "name" => "John" }, warning.row)
    assert_equal("category", warning.column)
    assert_equal("Multiple choices found", warning.message)
    assert_equal({ choice_count: 2 }, warning.details)
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
