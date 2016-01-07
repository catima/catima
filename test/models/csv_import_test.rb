require "test_helper"

class CSVImportTest < ActiveSupport::TestCase
  test "save!" do
    import = CSVImport.new
    import.creator = users(:one_admin)
    import.item_type = item_types(:one_author)
    import.file = sample_csv_file

    import.save!

    assert_equal(2, import.success_count)
    assert_empty(import.failures)

    items = Item.order(:id => "DESC").limit(2).map(&:behaving_as_type)

    assert_equal("Jenny", items.first.one_author_name_uuid)
    assert_equal("Jen", items.first.one_author_nickname_uuid)

    assert_equal("Matthew", items.second.one_author_name_uuid)
    assert_equal("Matt", items.second.one_author_nickname_uuid)
  end

  private

  def sample_csv_file
    file = Tempfile.new(["test", ".csv"])
    file.write <<~CSV
      name,nickname,ignore
      Matthew,Matt,3
      Jenny,Jen,6
    CSV
    file.rewind
    file
  end
end
