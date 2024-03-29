require "test_helper"

class CSVImportTest < ActiveSupport::TestCase
  include CSVFixtures

  should validate_presence_of(:creator)
  should validate_presence_of(:item_type)

  test "validates presence of file and encoding" do
    import = build_csv_import
    refute(import.valid?)
    refute_empty(import.errors[:file])
    refute_empty(import.errors[:file_encoding])

    import.file = sample_csv_file
    import.file_encoding = CSVImport::OPTION_DETECT_ENCODING
    import.validate
    assert_empty(import.errors[:file])
    assert_empty(import.errors[:file_encoding])
  end

  test "validates file has rows" do
    import = build_csv_import(:file => csv_file_with_no_data)
    refute(import.valid?)
    refute_empty(import.errors[:file])
  end

  test "validates file has mapped columns" do
    import = build_csv_import(:file => csv_file_with_bad_columns)
    refute(import.valid?)
    refute_empty(import.errors[:file])
  end

  test "validates good encoding chosen" do
    import = build_csv_import(
      :file => csv_file_windows1252,
      :file_encoding => "Windows-1252"
    )
    assert_equal(
      Encoding.find("Windows-1252"), import.rows.first["name"].encoding
    )
    assert_equal("Màtthew".encode("Windows-1252"), import.rows.first["name"])
  end

  test "validates bad encoding chosen" do
    import = build_csv_import(
      :file => csv_file_windows1252,
      :file_encoding => "macRoman"
    )
    assert_equal(Encoding.find("macRoman"), import.rows.first["name"].encoding)
    assert_not_equal("Màtthew".encode("macRoman"), import.rows.first["name"])
  end

  test "save!" do
    import = build_csv_import(
      :file => sample_csv_file,
      :file_encoding => CSVImport::OPTION_DETECT_ENCODING
    )

    import.save!

    assert_equal(2, import.success_count)
    assert_equal(1, import.failures.count)

    items = Item.order(:id => "DESC").limit(2).map(&:behaving_as_type)

    assert_equal("Jenny", items.first.one_author_name_uuid)
    assert_equal("Jen", items.first.one_author_nickname_uuid)

    assert_equal("Matthew", items.second.one_author_name_uuid)
    assert_equal("Matt", items.second.one_author_nickname_uuid)
  end

  private

  def build_csv_import(options={})
    import = CSVImport.new
    import.creator = users(:one_admin)
    import.item_type = item_types(:one_author)
    import.attributes = options
    import
  end

  def sample_csv_file
    csv_file_with_data <<~CSV
      name,nickname,ignore
      Matthew,Matt,3
      Jenny,Jen,6
      ,No name,10
    CSV
  end

  def csv_file_windows1252
    content = <<~CSV
      name,nickname,ignore
      Màtthew,Màtt,3
    CSV
    csv_file_with_data(
      content.encode("Windows-1252"),
      :encoding => "Windows-1252"
    )
  end

  def csv_file_with_no_data
    csv_file_with_data <<~CSV
      name,nickname,ignore
    CSV
  end

  def csv_file_with_bad_columns
    csv_file_with_data <<~CSV
      ignore1,ignore2
      value,value
    CSV
  end
end
