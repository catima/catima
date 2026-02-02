require "test_helper"

class CSVImport::ChoiceSetValueProcessorTest < ActiveSupport::TestCase
  test "process single choice - existing choice" do
    field = fields(:one_language_field)
    processor = CSVImport::ChoiceSetValueProcessor.new(field, :en)

    result = processor.process("Eng")

    assert_equal [choices(:one_english).id.to_s], result
  end

  test "process single choice - new choice" do
    field = fields(:one_language_field)
    processor = CSVImport::ChoiceSetValueProcessor.new(field, :en)

    assert_difference "Choice.count", 1 do
      result = processor.process("Italian")
      assert_not_nil result
      assert_equal 1, result.length

      choice = Choice.find(result.first)
      assert_equal "Italian", choice.short_name_en
      assert_equal choice_sets(:one_languages), choice.choice_set
      assert_nil choice.parent_id
    end
  end

  test "process multiple choices - mixed existing and new" do
    field = fields(:one_multiple_language_field)
    processor = CSVImport::ChoiceSetValueProcessor.new(field, :en)

    assert_difference "Choice.count", 1 do
      result = processor.process("Eng|German")

      assert_equal 2, result.length
      assert_includes result, choices(:one_english).id.to_s

      german_choice = Choice.find(result.last)
      assert_equal "German", german_choice.short_name_en
    end
  end

  test "process multiple choices separated by pipe" do
    field = fields(:one_multiple_language_field)
    processor = CSVImport::ChoiceSetValueProcessor.new(field, :en)

    result = processor.process("Eng|Eng (UK)")

    assert_equal 2, result.length
    assert_includes result, choices(:one_english).id.to_s
    assert_includes result, choices(:one_english_uk).id.to_s
  end

  test "process blank value returns nil" do
    field = fields(:one_language_field)
    processor = CSVImport::ChoiceSetValueProcessor.new(field, :en)

    assert_nil processor.process("")
    assert_nil processor.process(nil)
  end

  test "process trims whitespace from choice names" do
    field = fields(:one_language_field)
    processor = CSVImport::ChoiceSetValueProcessor.new(field, :en)

    result = processor.process("  Italian  ")

    choice = Choice.find(result.first)
    assert_equal "Italian", choice.short_name_en
  end

  test "process single field with multiple values takes only first" do
    field = fields(:one_language_field)
    processor = CSVImport::ChoiceSetValueProcessor.new(field, :en)

    # Even though multiple values are provided, only first is used for single field
    result = processor.process("Eng|Spanish")

    assert_equal [choices(:one_english).id.to_s], result
  end

  test "process ignores empty values in pipe-separated list" do
    field = fields(:one_multiple_language_field)
    processor = CSVImport::ChoiceSetValueProcessor.new(field, :en)

    result = processor.process("Eng||Spanish|")

    # Should only create/find non-empty values
    assert_equal 2, result.length
    assert_includes result, choices(:one_english).id.to_s
    assert_includes result, choices(:one_spanish).id.to_s
  end

  test "process finds hierarchical choices with parent" do
    field = fields(:one_language_field)
    processor = CSVImport::ChoiceSetValueProcessor.new(field, :en)

    # one_english_uk has one_english as parent (hierarchical choice)
    result = processor.process("Eng (UK)")

    assert_equal [choices(:one_english_uk).id.to_s], result
    assert_not_nil choices(:one_english_uk).parent_id
    assert_equal choices(:one_english).id, choices(:one_english_uk).parent_id
  end

  test "process warns when multiple choices have the same name" do
    field = fields(:one_language_field)

    # Create two choices with the same name
    choice1 = Choice.create!(
      catalog: catalogs(:one),
      choice_set: choice_sets(:one_languages),
      short_name_en: "Duplicate"
    )

    Choice.create!(
      catalog: catalogs(:one),
      choice_set: choice_sets(:one_languages),
      short_name_en: "Duplicate",
      parent_id: choices(:one_english).id # Child of English
    )

    processor = CSVImport::ChoiceSetValueProcessor.new(field, :en)

    assert_no_difference "Choice.count" do
      result = processor.process("Duplicate")

      # Should use the first match
      assert_equal [choice1.id.to_s], result

      # Should generate a warning
      assert_equal 1, processor.warnings.size
      warning = processor.warnings.first

      assert_equal :ambiguous_choice, warning[:type]
      assert_equal "Duplicate", warning[:choice_name]
      assert_equal 2, warning[:count]
      assert_equal choice1.id, warning[:selected_choice_id]
      assert_equal 2, warning[:details].size
    end
  end

  test "process with i18n field uses specified locale" do
    field = fields(:multilingual_i18n_language_field)

    # Test with French locale
    processor_fr = CSVImport::ChoiceSetValueProcessor.new(field, :fr)

    assert_difference "Choice.count", 1 do
      result = processor_fr.process("Allemand")

      choice = Choice.find(result.first)
      # All valid locales should have the same value as fallback
      assert_equal "Allemand", choice.short_name_fr
      assert_equal "Allemand", choice.short_name_en
      assert_equal "Allemand", choice.short_name_de
      assert_equal "Allemand", choice.short_name_it
      assert_equal choice_sets(:multilingual_languages), choice.choice_set
    end
  end

  test "process with i18n field matches existing choices in specified locale" do
    field = fields(:multilingual_i18n_language_field)

    # First create a choice with all locales (required by validation)
    french_choice = Choice.create!(
      catalog: catalogs(:multilingual),
      choice_set: choice_sets(:multilingual_languages),
      short_name_fr: "Portugais",
      short_name_en: "Portuguese",
      short_name_de: "Portugiesisch",
      short_name_it: "Portoghese"
    )

    # Now process should find it using French locale
    processor_fr = CSVImport::ChoiceSetValueProcessor.new(field, :fr)

    assert_no_difference "Choice.count" do
      result = processor_fr.process("Portugais")
      assert_equal [french_choice.id.to_s], result
    end
  end

  test "process with i18n field and multiple locales" do
    field = fields(:multilingual_i18n_language_field)

    # Create choice with all locales (required by validation)
    multilang_choice = Choice.create!(
      catalog: catalogs(:multilingual),
      choice_set: choice_sets(:multilingual_languages),
      short_name_en: "German",
      short_name_fr: "Allemand",
      short_name_de: "Deutsch",
      short_name_it: "Tedesco"
    )

    # Test finding with English
    processor_en = CSVImport::ChoiceSetValueProcessor.new(field, :en)
    result_en = processor_en.process("German")
    assert_equal [multilang_choice.id.to_s], result_en

    # Test finding with French
    processor_fr = CSVImport::ChoiceSetValueProcessor.new(field, :fr)
    result_fr = processor_fr.process("Allemand")
    assert_equal [multilang_choice.id.to_s], result_fr
  end
end
