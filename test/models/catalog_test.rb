require "test_helper"

class CatalogTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_presence_of(:slug)
  should validate_presence_of(:primary_language)

  should validate_uniqueness_of(:slug)

  should validate_inclusion_of(:primary_language).in_array(%w(de en fr it))

  test "other_languages accepts only validate locales" do
    catalog = catalogs(:one)
    catalog.other_languages = %w(en fr)
    assert(catalog.valid?)
    catalog.other_languages = %w(en es)
    refute(catalog.valid?)
  end
end
