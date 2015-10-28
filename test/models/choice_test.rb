require "test_helper"

class ChoiceTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)

  test "given catalog supporting one locale, validates names for it" do
    set = choice_sets(:one_languages) # supports only :en
    choice = Choice.new(:choice_set => set, :catalog => set.catalog)

    refute(choice.valid?)

    choice.short_name_en = "Eng"
    choice.long_name_en = "English"
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
end
