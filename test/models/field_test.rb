require "test_helper"

class FieldTest < ActiveSupport::TestCase
  should validate_presence_of(:item_type)
  should validate_presence_of(:slug)

  should validate_uniqueness_of(:slug).scoped_to(:item_type_id)
  should allow_value("hey").for(:slug)
  should_not allow_value("under_score").for(:slug)

  test "only one field can be primary per type" do
    title = fields(:one_title)
    summary = fields(:one_summary)

    assert(title.primary?)
    refute(summary.primary?)

    summary.update!(:primary => true)

    refute(title.reload.primary?)
    assert(summary.reload.primary?)

    # Field in another item type is not affected
    assert(fields(:one_author_name).primary?)
  end

  test "generates and assigns uuid" do
    SecureRandom.stubs(:uuid => "1234-abcd")

    field = Field::Text.create!(
      :item_type => item_types(:two_author),
      :name_en => "Text",
      :name_plural_en => "Texts",
      :slug => "text"
    )
    assert_equal("_1234_abcd", field.uuid)
  end

  test "given catalog supporting one locale, validates names for it" do
    it = item_types(:one_author) # supports only :en
    field = Field::Text.new(:item_type => it, :slug => "test-validation")

    refute(field.valid?)

    field.name_en = "Person"
    field.name_plural_en = "People"
    assert(field.valid?)
  end

  test "given catalog supporting many locales, validates names for all" do
    it = item_types(:multilingual_author)
    field = Field::Text.new(:item_type => it, :slug => "test-validation")

    refute(field.valid?)

    field.name_de = "Mensch"
    field.name_plural_de = "Menschen"
    field.name_en = "Person"
    field.name_plural_en = "People"
    field.name_fr = "Personne"
    field.name_plural_fr = "Personnes"
    field.name_it = "Persona"
    field.name_plural_it = "Persone"
    assert(field.valid?)
  end
end
