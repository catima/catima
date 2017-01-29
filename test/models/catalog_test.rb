require "test_helper"

class CatalogTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_presence_of(:slug)
  should validate_presence_of(:primary_language)

  should validate_uniqueness_of(:slug)
  should allow_value("hey").for(:slug)
  should allow_value("good-times").for(:slug)
  should allow_value("w00t").for(:slug)

  should_not allow_value("under_score").for(:slug)
  should_not allow_value("café").for(:slug)
  should_not allow_value("admin").for(:slug)
  should_not allow_value("manage").for(:slug)
  should_not allow_value("new").for(:slug)
  should_not allow_value("edit").for(:slug)
  should_not allow_value("api").for(:slug)
  should_not allow_value("de").for(:slug)
  should_not allow_value("en").for(:slug)
  should_not allow_value("fr").for(:slug)
  should_not allow_value("it").for(:slug)

  should validate_inclusion_of(:primary_language).in_array(%w(de en fr it))

  test "other_languages accepts only validate locales" do
    catalog = catalogs(:one)
    catalog.other_languages = %w(en fr)
    assert(catalog.valid?)
    catalog.other_languages = %w(en es)
    refute(catalog.valid?)
  end

  test "#public_items for non-reviewed catalog" do
    catalog = catalogs(:one)
    Review.expects(:public_items_in_catalog).never
    assert_equal(catalog.items, catalog.public_items)
  end

  test "#public_items for reviewed catalog" do
    catalog = catalogs(:reviewed)
    Review.stubs(:public_items_in_catalog).with(catalog).returns(:filtered)
    assert_equal(:filtered, catalog.public_items)
  end
end
