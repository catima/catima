require "test_helper"

class CSVImport::ReaderTest < ActiveSupport::TestCase
  CSV_CONTENT = "one,two,three\n1,2,3\n4,5,6\n".freeze

  EXPECTED_ROWS = [
    { "one" => "1", "two" => "2", "three" => "3" },
    { "one" => "4", "two" => "5", "three" => "6" }
  ].freeze

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  def make_tempfile(binary_content)
    file = Tempfile.new(["test", ".csv"])
    file.binmode
    file.write(binary_content)
    file.rewind
    file
  end

  def assert_parsed_correctly(reader)
    assert_equal(2, reader.rows.count)
    EXPECTED_ROWS.each_with_index do |expected, i|
      assert_equal(expected, reader.rows[i].to_hash)
    end
  end

  # ---------------------------------------------------------------------------
  # UTF-8 (plain)
  # ---------------------------------------------------------------------------

  test "UTF-8 CSV file can be parsed" do
    file = make_tempfile(CSV_CONTENT.encode("UTF-8"))
    reader = CSVImport::Reader.new(file)
    assert_equal("UTF-8", reader.encoding.to_s)
    assert_parsed_correctly(reader)
  end

  # ---------------------------------------------------------------------------
  # UTF-8 with BOM
  # ---------------------------------------------------------------------------

  test "UTF-8 CSV with BOM is parsed and BOM is stripped" do
    bom = "\xEF\xBB\xBF".b
    file = make_tempfile(bom + CSV_CONTENT.encode("UTF-8").b)
    reader = CSVImport::Reader.new(file)
    assert_parsed_correctly(reader)
    assert_equal("one", reader.rows[0].headers.first,
                 "BOM should not appear as part of the first column name")
  end

  # ---------------------------------------------------------------------------
  # UTF-16LE with BOM
  # ---------------------------------------------------------------------------

  test "UTF-16LE CSV with BOM is transcoded to UTF-8 and parsed" do
    bom = "\xFF\xFE".b
    content = bom + CSV_CONTENT.encode("UTF-16LE").b
    file = make_tempfile(content)
    reader = CSVImport::Reader.new(file)
    assert_equal("UTF-8", reader.encoding.to_s)
    assert_parsed_correctly(reader)
  end

  # ---------------------------------------------------------------------------
  # UTF-16LE without BOM
  # ---------------------------------------------------------------------------

  test "UTF-16LE CSV without BOM is transcoded to UTF-8 and parsed" do
    file = make_tempfile(CSV_CONTENT.encode("UTF-16LE").b)
    reader = CSVImport::Reader.new(file)
    assert_equal("UTF-8", reader.encoding.to_s)
    assert_parsed_correctly(reader)
  end

  # ---------------------------------------------------------------------------
  # Windows-1252
  # ---------------------------------------------------------------------------

  test "Windows-1252 CSV with accented characters is parsed" do
    # "café,résumé" encoded in Windows-1252
    content = "name,value\ncaf\xE9,r\xE9sum\xE9\n".b
    file = make_tempfile(content)
    reader = CSVImport::Reader.new(file)
    assert_equal("Windows-1252", reader.encoding.to_s)
    assert_equal(1, reader.rows.count)
    assert_equal("caf\xE9".force_encoding("Windows-1252"), reader.rows[0]["name"])
  end

  # ---------------------------------------------------------------------------
  # macRoman
  # ---------------------------------------------------------------------------

  test "macRoman CSV with bytes undefined in CP1252 is parsed" do
    # 0x81 is undefined in CP1252 but maps to Å in macRoman
    content = "name\n\x81test\n".b
    file = make_tempfile(content)
    reader = CSVImport::Reader.new(file)
    assert_equal("macRoman", reader.encoding.to_s)
    assert_equal(1, reader.rows.count)
    assert_equal("\x81test".force_encoding("macRoman"), reader.rows[0]["name"])
  end

  # ---------------------------------------------------------------------------
  # Specified encoding overrides auto-detection
  # ---------------------------------------------------------------------------

  test "specified encoding is used instead of auto-detection" do
    file = make_tempfile(CSV_CONTENT.encode("Windows-1252"))
    reader = CSVImport::Reader.new(file, "Windows-1252")
    assert_equal("Windows-1252", reader.encoding.to_s)
    assert_equal(2, reader.rows.count)
  end
end
