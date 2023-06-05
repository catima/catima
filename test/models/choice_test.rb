require "test_helper"

class ChoiceTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)

  test "given catalog supporting one locale, validates names for it" do
    set = choice_sets(:one_languages) # supports only :en
    choice = Choice.new(:choice_set => set, :catalog => set.catalog)

    refute(choice.valid?)

    choice.short_name_en = "Eng"
    assert(choice.valid?)
  end

  test "given catalog supporting many locales, validates names for all" do
    set = choice_sets(:multilingual_languages)
    ch = Choice.new(:choice_set => set, :catalog => set.catalog)

    refute(ch.valid?)

    ch.short_name_de = "Mensch"
    ch.long_name_de = "Menschen"
    ch.short_name_en = "Person"
    ch.long_name_en = "People"
    ch.short_name_fr = "Personne"
    ch.long_name_fr = "Personnes"
    ch.short_name_it = "Persona"
    ch.long_name_it = "Persone"

    assert(ch.valid?)
  end

  test "#long_display_name uses short name if long name is absent" do
    ch = Choice.new(:short_name_en => "short", :long_name_en => "")
    assert_equal("short", ch.long_display_name_en)

    ch.long_name_en = "long"
    assert_equal("long", ch.long_display_name_en)
  end

  test "a category cannot be used twice in the same choice set" do
    set = choice_sets(:one_category)

    ch_valid = Choice.new(
      :choice_set => set,
      :catalog => set.catalog,
      :short_name_en => "Without existing category",
      :long_name_en => "Without existing category",
      :category => categories(:one)
    )

    assert(ch_valid.valid?)

    ch_invalid = Choice.new(
      :choice_set => set,
      :catalog => set.catalog,
      :short_name_en => "With existing category",
      :long_name_en => "With existing category",
      :category => categories(:language)
    )

    refute(ch_invalid.valid?)
  end
end
