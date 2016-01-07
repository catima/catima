require "test_helper"

class CSVImportTest < ActiveSupport::TestCase
  should validate_presence_of(:creator)
  should validate_presence_of(:item_type)

  test "validates presence of file" do
    import = build_csv_import
    refute(import.valid?)
    refute_empty(import.errors[:file])

    import.file = sample_csv_file
    import.validate
    assert_empty(import.errors[:file])
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

  test "save!" do
    import = build_csv_import(:file => sample_csv_file)

    import.save!

    assert_equal(3, import.success_count)
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

  def csv_file_with_data(data)
    file = Tempfile.new(["test", ".csv"])
    file.write(data)
    file.rewind
    file
  end
end
