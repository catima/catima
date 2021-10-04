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

  test "slug has suffix after deactivation and no suffix otherwise" do
    catalog = catalogs(:one)
    catalog.update(deactivated_at: DateTime.current)
    assert(catalog.inactive_suffix?)
    catalog.update(deactivated_at: nil)
    assert_not(catalog.inactive_suffix?)
  end

  test "slug updated to unique value on reactivation" do
    c1 = catalogs(:one)
    c2 = catalogs(:two)
    new_slug = c1.slug
    # Deactivate the first catalog
    c1.update(deactivated_at: DateTime.current)
    assert(c1.inactive_suffix?)
    # Set the slug of the second catalog to the first one
    c2.update(slug: new_slug)
    # Reactivate the first catalog; slug should be different from initial slug
    c1.update(deactivated_at: nil)
    assert_not_equal(c1.slug, new_slug)
  end

  test "clone!" do
    catalog = catalogs(:two)
    cloned = catalog.clone!("new-unique-slug")
    assert_equal(catalog.item_types.pluck(:slug), cloned.item_types.pluck(:slug))
    assert_equal(catalog.item_types.first.fields.pluck(:name_translations), cloned.item_types.first.fields.pluck(:name_translations))
    assert_equal(catalog.choice_sets.pluck(:name), cloned.choice_sets.pluck(:name))
    assert_equal(catalog.menu_items.pluck(:title), cloned.menu_items.pluck(:title))
    assert_equal(catalog.categories.pluck(:name), cloned.categories.pluck(:name))
    assert_equal(catalog.advanced_search_configurations.pluck(:slug), cloned.advanced_search_configurations.pluck(:slug))
  end
end
