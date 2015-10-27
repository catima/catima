require "test_helper"

class ItemTypeTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:slug)

  should validate_uniqueness_of(:slug).scoped_to(:catalog_id)
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
end
