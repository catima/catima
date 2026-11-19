require "test_helper"

class ItemTypeTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:slug)

  should validate_uniqueness_of(:slug).scoped_to(:catalog_id, :deleted_at)
  should allow_value("hey").for(:slug)
  should_not allow_value("under_score").for(:slug)

  test "given catalog supporting one locale, validates names for it" do
    catalog = catalogs(:one) # supports only :en
    it = ItemType.new(:catalog => catalog, :slug => "test-validation")

    refute(it.valid?)

    it.name_en = "Person"
    it.name_plural_en = "People"
    assert(it.valid?)
  end

  test "given catalog supporting many locales, validates names for all" do
    catalog = catalogs(:multilingual)
    it = ItemType.new(:catalog => catalog, :slug => "test-validation")

    refute(it.valid?)

    it.name_de = "Mensch"
    it.name_plural_de = "Menschen"
    it.name_en = "Person"
    it.name_plural_en = "People"
    it.name_fr = "Personne"
    it.name_plural_fr = "Personnes"
    it.name_it = "Persona"
    it.name_plural_it = "Persone"
    assert(it.valid?)
  end

  test "#all_fields includes fields belonging to nested categories" do
    fields = item_types(:nested_vehicle).all_fields
    assert_instance_of(Array, fields)
    assert_equal(6, fields.size)
    assert_includes(fields, fields(:nested_vehicle_name))
    assert_includes(fields, fields(:nested_vehicle_type))
    assert_includes(fields, fields(:nested_car_cupholders))
    assert_includes(fields, fields(:nested_car_color))
    assert_includes(fields, fields(:nested_car_manufacture_date))
    assert_includes(fields, fields(:nested_bicycle_speeds))
  end

  test "soft deleting an item type logs a DELETE with the new slug" do
    item_type = item_types(:two_author)
    old_slug = item_type.slug
    item_type.slug = "#{old_slug}-deleted"

    assert_difference("EntryLog.count", 1) do
      item_type.soft_destroy_and_log!(author: users(:two_admin), catalog: catalogs(:two))
    end

    last_log = EntryLog.order(:id).last
    assert_equal item_type, last_log.subject
    assert_equal "DELETE", last_log.action
    assert last_log.record_changes.key?("deleted_at")
    assert_equal ["#{old_slug}-deleted"], last_log.record_changes["slug"].last(1)
  end
end
