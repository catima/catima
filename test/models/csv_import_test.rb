require "test_helper"

class CSVImportTest < ActiveSupport::TestCase
  include CSVFixtures

  should validate_presence_of(:creator)
  should validate_presence_of(:item_type)

  test "validates presence of file and encoding" do
    import = build_csv_import
    refute(import.valid?)
    refute_empty(import.errors[:file])
    refute_empty(import.errors[:file_encoding])

    import.file = sample_csv_file
    import.file_encoding = CSVImport::OPTION_DETECT_ENCODING
    import.validate
    assert_empty(import.errors[:file])
    assert_empty(import.errors[:file_encoding])
  end

  test "validates file has rows" do
    import = build_csv_import(:file => csv_file_with_no_data)
    refute(import.valid?)
    refute_empty(import.errors[:file])
  end

  test "validates file has mapped columns" do
    import = build_csv_import(:file => csv_file_with_bad_columns)
    refute(import.valid?)
    refute_empty(import.errors[:file])
  end

  test "validates good encoding chosen" do
    import = build_csv_import(
      :file => csv_file_windows1252,
      :file_encoding => "Windows-1252"
    )
    assert_equal(
      Encoding.find("Windows-1252"), import.rows.first["name"].encoding
    )
    assert_equal("Màtthew".encode("Windows-1252"), import.rows.first["name"])
  end

  test "validates bad encoding chosen" do
    import = build_csv_import(
      :file => csv_file_windows1252,
      :file_encoding => "macRoman"
    )
    assert_equal(Encoding.find("macRoman"), import.rows.first["name"].encoding)
    assert_not_equal("Màtthew".encode("macRoman"), import.rows.first["name"])
  end

  test "save!" do
    import = build_csv_import(
      :file => sample_csv_file,
      :file_encoding => CSVImport::OPTION_DETECT_ENCODING
    )

    import.save!

    assert_equal(2, import.success_count)
    assert_equal(1, import.failures.count)

    items = Item.order(:id => "DESC").limit(2).map(&:behaving_as_type)

    assert_equal("Jenny", items.first.one_author_name_uuid)
    assert_equal("Jen", items.first.one_author_nickname_uuid)

    assert_equal("Matthew", items.second.one_author_name_uuid)
    assert_equal("Matt", items.second.one_author_nickname_uuid)
  end

  test "save! with choice set fields" do
    import = build_csv_import(
      :file => csv_file_with_choice_sets,
      :file_encoding => CSVImport::OPTION_DETECT_ENCODING
    )

    initial_choice_count = Choice.count

    import.save!

    assert_equal(3, import.success_count)
    assert_equal(0, import.failures.count)

    items = Item.order(:id => "DESC").limit(3).map(&:behaving_as_type)

    # Third item - existing single choice and multiple choices
    assert_equal("Author Three", items.first.one_author_name_uuid)
    assert_equal([choices(:one_english).id.to_s], items.first.data["one_language_field_uuid"])
    assert_equal(
      [choices(:one_english).id.to_s, choices(:one_spanish).id.to_s],
      items.first.one_multiple_language_field_uuid
    )

    # Second item - new single choice, mixed multiple choices
    assert_equal("Author Two", items.second.one_author_name_uuid)
    new_italian = Choice.where(catalog: catalogs(:one))
                        .short_named("Italian", :en)
                        .first
    assert_not_nil(new_italian)
    assert_equal([new_italian.id.to_s], items.second.data["one_language_field_uuid"])
    assert_equal(
      [choices(:one_english).id.to_s, new_italian.id.to_s],
      items.second.one_multiple_language_field_uuid
    )

    # First item - new single and multiple choices
    assert_equal("Author One", items.third.one_author_name_uuid)
    new_german = Choice.where(catalog: catalogs(:one))
                       .short_named("German", :en)
                       .first
    assert_not_nil(new_german)
    assert_equal([new_german.id.to_s], items.third.data["one_language_field_uuid"])

    new_portuguese = Choice.where(catalog: catalogs(:one))
                           .short_named("Portuguese", :en)
                           .first
    assert_not_nil(new_portuguese)
    assert_includes(items.third.one_multiple_language_field_uuid, new_german.id.to_s)
    assert_includes(items.third.one_multiple_language_field_uuid, new_portuguese.id.to_s)

    # Verify new choices were created
    assert_equal(initial_choice_count + 3, Choice.count)
  end

  test "save! with i18n choice set fields" do
    import = CSVImport.new
    import.creator = users(:one_admin)
    import.item_type = item_types(:multilingual_author)
    import.file = csv_file_with_i18n_choice_sets
    import.file_encoding = CSVImport::OPTION_DETECT_ENCODING

    initial_choice_count = Choice.count

    import.save!

    assert_equal(3, import.success_count)
    assert_equal(0, import.failures.count)

    items = Item.where(item_type: item_types(:multilingual_author))
                .order(:id => "DESC")
                .limit(3)
                .map(&:behaving_as_type)

    # Third item - Should have a choice with both EN and FR translations
    assert_equal("Auteur Trois", items.first.multilingual_author_name_uuid_fr)
    french_choice = Choice.where(catalog: catalogs(:multilingual))
                          .short_named("French", :en)
                          .first
    assert_not_nil(french_choice)
    assert_equal("French", french_choice.short_name_en)
    assert_equal("Français", french_choice.short_name_fr)
    assert_equal(french_choice.id.to_s, items.first.multilingual_i18n_language_field_uuid)

    # Second item - German only in English (French will use fallback)
    assert_equal("Auteur Deux", items.second.multilingual_author_name_uuid_fr)
    german_choice = Choice.where(catalog: catalogs(:multilingual))
                          .short_named("German", :en)
                          .first
    assert_not_nil(german_choice)
    assert_equal(german_choice.id.to_s, items.second.multilingual_i18n_language_field_uuid)

    # First item - Portugais only in French (English will use fallback)
    assert_equal("Auteur Un", items.third.multilingual_author_name_uuid_fr)
    portugais_choice = Choice.where(catalog: catalogs(:multilingual))
                             .short_named("Portugais", :fr)
                             .first
    assert_not_nil(portugais_choice)
    assert_equal([portugais_choice.id.to_s], items.third.data["multilingual_i18n_language_field_uuid"])

    # Verify new choices were created (3 new choices)
    assert_equal(initial_choice_count + 3, Choice.count)
  end

  test "save! with i18n choice set fields and multiple choices" do
    import = CSVImport.new
    import.creator = users(:one_admin)
    import.item_type = item_types(:multilingual_author)
    import.file = csv_file_with_i18n_multiple_choice_sets
    import.file_encoding = CSVImport::OPTION_DETECT_ENCODING

    initial_choice_count = Choice.count

    import.save!

    assert_equal(1, import.success_count)
    assert_equal(0, import.failures.count)

    item = Item.where(item_type: item_types(:multilingual_author))
               .order(:id => "DESC")
               .limit(1)
               .first
               .behaving_as_type

    # Check the author name
    assert_equal("Auteur Un", item.multilingual_author_name_uuid_fr)

    # Check that we have the tag field with multiple values
    tags = item.multilingual_i18n_tag_field_uuid
    assert_equal(2, tags.size)

    # Verify "new" choice has both translations
    new_choice = Choice.where(catalog: catalogs(:multilingual))
                       .short_named("new", :en)
                       .first
    assert_not_nil(new_choice)
    assert_equal("new", new_choice.short_name_en)
    assert_equal("nouveau", new_choice.short_name_fr)
    assert_includes(tags, new_choice.id.to_s)

    # Verify "feature" choice has both translations
    feature_choice = Choice.where(catalog: catalogs(:multilingual))
                           .short_named("feature", :en)
                           .first
    assert_not_nil(feature_choice)
    assert_equal("feature", feature_choice.short_name_en)
    assert_equal("fonctionnalité", feature_choice.short_name_fr)
    assert_includes(tags, feature_choice.id.to_s)

    # Verify new choices were created
    assert_equal(initial_choice_count + 2, Choice.count)
  end

  test "save! with reference fields - single reference" do
    # Create reference items
    ref_author = item_types(:one_author).items.create!(
      :catalog => catalogs(:one),
      :creator => users(:one_admin),
      :data => { "one_author_name_uuid" => "Referenced Author" }
    )

    import = build_csv_import(
      :file => csv_file_with_single_reference(ref_author.id),
      :file_encoding => CSVImport::OPTION_DETECT_ENCODING
    )

    import.save!

    assert_equal(1, import.success_count)
    assert_equal(0, import.failures.count)

    item = Item.order(:id => "DESC").first.behaving_as_type
    assert_equal("Author One", item.one_author_name_uuid)
    assert_equal(ref_author.id, item.data["one_author_collaborator_uuid"])
  end

  test "save! with reference fields - multiple references" do
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

    import = build_csv_import(
      :file => csv_file_with_multiple_references(ref_author1.id, ref_author2.id),
      :file_encoding => CSVImport::OPTION_DETECT_ENCODING
    )

    import.save!

    assert_equal(1, import.success_count)
    assert_equal(0, import.failures.count)

    item = Item.order(:id => "DESC").first.behaving_as_type
    assert_equal("Author One", item.one_author_name_uuid)
    assert_equal([ref_author1.id.to_s, ref_author2.id.to_s], item.one_author_other_collaborators_uuid)
  end

  test "save! with reference fields - invalid ID causes failure" do
    import = build_csv_import(
      :file => csv_file_with_invalid_reference,
      :file_encoding => CSVImport::OPTION_DETECT_ENCODING
    )

    import.save!

    assert_equal(0, import.success_count)
    assert_equal(1, import.failures.count)

    failure = import.failures.first
    assert_match(/is not a valid ID/, failure.column_errors["collaborator"].join)
  end

  test "save! with reference fields - non-existent item causes failure" do
    import = build_csv_import(
      :file => csv_file_with_nonexistent_reference,
      :file_encoding => CSVImport::OPTION_DETECT_ENCODING
    )

    import.save!

    assert_equal(0, import.success_count)
    assert_equal(1, import.failures.count)

    failure = import.failures.first
    assert_match(/Item #999999 does not exist/, failure.column_errors["collaborator"].join)
  end

  private

  def build_csv_import(options={})
    import = CSVImport.new
    import.creator = users(:one_admin)
    import.item_type = item_types(:one_author)
    import.attributes = options
    import
  end

  def sample_csv_file
    csv_file_with_data <<~CSV
      name,nickname,ignore
      Matthew,Matt,3
      Jenny,Jen,6
      ,No name,10
    CSV
  end

  def csv_file_windows1252
    content = <<~CSV
      name,nickname,ignore
      Màtthew,Màtt,3
    CSV
    csv_file_with_data(
      content.encode("Windows-1252"),
      :encoding => "Windows-1252"
    )
  end

  def csv_file_with_no_data
    csv_file_with_data <<~CSV
      name,nickname,ignore
    CSV
  end

  def csv_file_with_bad_columns
    csv_file_with_data <<~CSV
      ignore1,ignore2
      value,value
    CSV
  end

  def csv_file_with_choice_sets
    csv_file_with_data <<~CSV
      name,language-single,languages-multiple
      Author One,German,German|Portuguese
      Author Two,Italian,Eng|Italian
      Author Three,Eng,Eng|Spanish
    CSV
  end

  def csv_file_with_i18n_choice_sets
    csv_file_with_data <<~CSV
      name (fr),language-i18n (fr),language-i18n (en)
      Auteur Un,Portugais,
      Auteur Deux,,German
      Auteur Trois,Français,French
    CSV
  end

  def csv_file_with_i18n_multiple_choice_sets
    csv_file_with_data <<~CSV
      name (fr),tag (en),tag (fr)
      Auteur Un,new|feature,nouveau|fonctionnalité
    CSV
  end

  def csv_file_with_single_reference(ref_id)
    csv_file_with_data <<~CSV
      name,collaborator
      Author One,#{ref_id}
    CSV
  end

  def csv_file_with_multiple_references(ref_id1, ref_id2)
    csv_file_with_data <<~CSV
      name,other-collaborator
      Author One,#{ref_id1}|#{ref_id2}
    CSV
  end

  def csv_file_with_invalid_reference
    csv_file_with_data <<~CSV
      name,collaborator
      Author One,invalid_id
    CSV
  end

  def csv_file_with_nonexistent_reference
    csv_file_with_data <<~CSV
      name,collaborator
      Author One,999999
    CSV
  end
end
