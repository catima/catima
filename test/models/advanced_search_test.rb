require "test_helper"

class AdvancedSearchTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:item_type)

  test "generates and assigns uuid" do
    SecureRandom.stubs(:uuid => "1234-abcd")

    search = AdvancedSearch.create!(
      :catalog => catalogs(:two),
      :item_type => item_types(:two_author)
    )
    assert_equal("1234-abcd", search.uuid)
  end

  test "assigns current locale" do
    search = AdvancedSearch.new(
      :catalog => catalogs(:two),
      :item_type => item_types(:two_author)
    )
    I18n.with_locale(:it) { search.save! }
    assert_equal("it", search.locale)
  end
end
