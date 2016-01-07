require "test_helper"

class CSVImport::FieldWithLocaleTest < ActiveSupport::TestCase
  test "attribute_name" do
    nickname = CSVImport::FieldWithLocale.new(fields(:one_author_nickname), :en)
    bio_fr = CSVImport::FieldWithLocale.new(
      fields(:multilingual_author_bio),
      :fr
    )

    assert_equal("one_author_nickname_uuid", nickname.attribute_name)
    assert_equal("multilingual_author_bio_uuid_fr", bio_fr.attribute_name)
  end
end
