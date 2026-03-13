require "test_helper"

class CSVImport::EncodingDetectorTest < ActiveSupport::TestCase
  def detect(raw)
    CSVImport::EncodingDetector.detect_from_string(raw)
  end

  # ---------------------------------------------------------------------------
  # BOM detection
  # ---------------------------------------------------------------------------

  test "detects UTF-8 BOM" do
    raw = "\xEF\xBB\xBF".b + "name\nfoo\n".b
    result = detect(raw)
    assert_equal("UTF-8", result[:encoding])
    assert_equal(1.0, result[:confidence])
    assert(result[:has_bom])
  end

  test "detects UTF-16LE BOM" do
    raw = "\xFF\xFE".b + "name\nfoo\n".encode("UTF-16LE").b
    result = detect(raw)
    assert_equal("UTF-16LE", result[:encoding])
    assert_equal(1.0, result[:confidence])
    assert(result[:has_bom])
  end

  # ---------------------------------------------------------------------------
  # Pure ASCII / UTF-8
  # ---------------------------------------------------------------------------

  test "detects pure ASCII as UTF-8 with confidence 1.0" do
    result = detect("name,value\nfoo,bar\n")
    assert_equal("UTF-8", result[:encoding])
    assert_equal(1.0, result[:confidence])
    assert_not(result[:has_bom])
  end

  test "detects valid UTF-8 multibyte as UTF-8 with confidence 0.99" do
    result = detect("name\ncafé\n")
    assert_equal("UTF-8", result[:encoding])
    assert_equal(0.99, result[:confidence])
    assert_not(result[:has_bom])
  end

  # ---------------------------------------------------------------------------
  # UTF-16LE without BOM
  # ---------------------------------------------------------------------------

  test "detects UTF-16LE without BOM" do
    raw = "name,value\nfoo,bar\n".encode("UTF-16LE").b
    result = detect(raw)
    assert_equal("UTF-16LE", result[:encoding])
    assert_not(result[:has_bom])
  end

  # ---------------------------------------------------------------------------
  # Windows-1252
  # ---------------------------------------------------------------------------

  test "detects Windows-1252 via CP1252 signature bytes" do
    # 0x80 = € in CP1252
    raw = "name\ncaf\x80\n".b
    result = detect(raw)
    assert_equal("Windows-1252", result[:encoding])
    assert_not(result[:has_bom])
  end

  # ---------------------------------------------------------------------------
  # macRoman
  # ---------------------------------------------------------------------------

  test "detects macRoman via bytes undefined in CP1252" do
    # 0x81 is undefined in CP1252, maps to Å in macRoman
    raw = "name\n\x81test\n".b
    result = detect(raw)
    assert_equal("macRoman", result[:encoding])
    assert_not(result[:has_bom])
  end

  # ---------------------------------------------------------------------------
  # Empty input
  # ---------------------------------------------------------------------------

  test "returns unknown for empty input" do
    result = detect("")
    assert_equal("unknown", result[:encoding])
    assert_equal(0.0, result[:confidence])
  end

  # ---------------------------------------------------------------------------
  # strip_bom
  # ---------------------------------------------------------------------------

  test "strip_bom removes UTF-8 BOM" do
    str = "\xEF\xBB\xBFhello".dup.force_encoding("UTF-8")
    assert_equal("hello", CSVImport::EncodingDetector.strip_bom(str))
  end

  test "strip_bom removes UTF-16LE BOM" do
    str = "\xFF\xFE#{'hello'.encode('UTF-16LE').b}".b
    stripped = CSVImport::EncodingDetector.strip_bom(str)
    assert_not(stripped.b.start_with?("\xFF\xFE".b))
  end

  test "strip_bom is a no-op when no BOM is present" do
    str = "hello"
    assert_equal("hello", CSVImport::EncodingDetector.strip_bom(str))
  end
end
