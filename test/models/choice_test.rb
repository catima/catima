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

  def create_choices(set, names, parent: nil)
    names.each_with_index.map do |name, index|
      Choice.create!(choice_set: set, catalog: set.catalog, parent: parent, short_name_en: name, position: index + 1)
    end
  end

  def count_choice_updates
    updates = 0
    counter = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
      updates += 1 if payload[:sql].start_with?('UPDATE "choices"')
    end
    yield
    updates
  ensure
    ActiveSupport::Notifications.unsubscribe(counter)
  end

  test "destroying a choice renumbers its siblings" do
    set = ChoiceSet.create!(catalog: catalogs(:two), name: "Renumbering")
    first, middle, last = create_choices(set, %w(First Middle Last))

    middle.destroy

    assert_equal [first.id, last.id], set.choices.where(parent_id: nil).ordered.pluck(:id)
    assert_equal [1, 2], set.choices.where(parent_id: nil).ordered.pluck(:position)
  end

  test "destroying a choice with children does not renumber the children one by one" do
    set = ChoiceSet.create!(catalog: catalogs(:two), name: "Cascade")
    parent = create_choices(set, %w(Parent)).first
    children = create_choices(set, %w(A B C D E), parent: parent)

    updates = count_choice_updates { Choice.find(parent.id).destroy }

    assert_equal 0, updates
    assert_empty Choice.where(id: [parent.id, *children.map(&:id)])
  end
end
