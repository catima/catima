require "test_helper"

class CSVImport::ReferenceValueProcessorTest < ActiveSupport::TestCase
  test "process with valid single reference" do
    field = fields(:one_author_collaborator)

    # Create a reference item
    ref_author = item_types(:one_author).items.create!(
      :catalog => catalogs(:one),
      :creator => users(:one_admin),
      :data => { "one_author_name_uuid" => "Referenced Author" }
    )

    processor = CSVImport::ReferenceValueProcessor.new(field)
    result = processor.process(ref_author.id.to_s)

    assert_equal(ref_author.id, result)
    assert_empty(processor.errors)
  end

  test "process with valid multiple references" do
    field = fields(:one_author_other_collaborators)

    # Create reference items
    ref_author1 = item_types(:one_author).items.create!(
      :catalog => catalogs(:one),
      :creator => users(:one_admin),
      :data => { "one_author_name_uuid" => "Collaborator 1" }
    )
    ref_author2 = item_types(:one_author).items.create!(
      :catalog => catalogs(:one),
      :creator => users(:one_admin),
      :data => { "one_author_name_uuid" => "Collaborator 2" }
    )

    processor = CSVImport::ReferenceValueProcessor.new(field)
    result = processor.process("#{ref_author1.id}|#{ref_author2.id}")

    assert_equal([ref_author1.id.to_s, ref_author2.id.to_s], result)
    assert_empty(processor.errors)
  end

  test "process with blank value" do
    field = fields(:one_author_collaborator)
    processor = CSVImport::ReferenceValueProcessor.new(field)

    result = processor.process("")
    assert_nil(result)
    assert_empty(processor.errors)
  end

  test "process with invalid ID format" do
    field = fields(:one_author_collaborator)
    processor = CSVImport::ReferenceValueProcessor.new(field)

    result = processor.process("not_a_number")

    assert_nil(result)
    assert_equal(1, processor.errors.size)
    assert_match(/is not a valid ID/, processor.errors.first)
  end

  test "process with non-existent item" do
    field = fields(:one_author_collaborator)
    processor = CSVImport::ReferenceValueProcessor.new(field)

    result = processor.process("999999")

    assert_nil(result)
    assert_equal(1, processor.errors.size)
    assert_match(/Item #999999 does not exist/, processor.errors.first)
  end

  test "process with mixed valid and invalid IDs" do
    field = fields(:one_author_other_collaborators)

    # Create one valid reference
    ref_author = item_types(:one_author).items.create!(
      :catalog => catalogs(:one),
      :creator => users(:one_admin),
      :data => { "one_author_name_uuid" => "Valid Author" }
    )

    processor = CSVImport::ReferenceValueProcessor.new(field)
    result = processor.process("#{ref_author.id}|999999|invalid")

    # Only the valid ID should be returned
    assert_equal([ref_author.id.to_s], result)
    assert_equal(2, processor.errors.size)
  end

  test "process handles empty values in pipe-separated list" do
    field = fields(:one_author_other_collaborators)

    # Create reference items
    ref_author1 = item_types(:one_author).items.create!(
      :catalog => catalogs(:one),
      :creator => users(:one_admin),
      :data => { "one_author_name_uuid" => "Collaborator 1" }
    )
    ref_author2 = item_types(:one_author).items.create!(
      :catalog => catalogs(:one),
      :creator => users(:one_admin),
      :data => { "one_author_name_uuid" => "Collaborator 2" }
    )

    processor = CSVImport::ReferenceValueProcessor.new(field)
    # Test with empty value between pipes
    result = processor.process("#{ref_author1.id}||#{ref_author2.id}")

    assert_equal([ref_author1.id.to_s, ref_author2.id.to_s], result)
    assert_empty(processor.errors)
  end
end
