require "test_helper"

class CSVImport::ReaderTest < ActiveSupport::TestCase
  test "CSV file can be parsed" do
    file = Tempfile.new(["test", ".csv"])
    file.write <<~CSV
      one,two,three
      1,2,3
      4,5,6
    CSV
    file.rewind

    reader = CSVImport::Reader.new(file)
    assert_equal("UTF-8", reader.encoding.to_s)
    assert_equal(2, reader.rows.count)
    assert_equal(
      { "one" => "1", "two" => "2", "three" => "3" },
      reader.rows[0].to_hash
    )
    assert_equal(
      { "one" => "4", "two" => "5", "three" => "6" },
      reader.rows[1].to_hash
    )
  end
end
