require 'fileutils'

# Database name : Catalog slug
# Tables :
#   - ItemTypes slug
#   - Multiple reference fields slug of ItemTypes
#   - ChoiceSets
#   - Categories
# Columns :
#   - Fields slug of ItemTypes
#   - Choices
# rubocop:disable Metrics/ClassLength
class Dump::SqlDump < ::Dump
  include CatalogAdmin::SqlDumpHelper

  COMMON_SQL_COLUMNS = {
    :id => "INT",
    :created_at => "TIMESTAMP DEFAULT CURRENT_TIMESTAMP",
    :updated_at => "TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
  }.freeze

  def initialize
  end

  def dump(catalog, directory)
    cat = Catalog.find_by(slug: catalog)
    raise "ERROR. Catalog '#{catalog}' not found." if cat.nil?

    # Check if directory exists; create if necessary,
    # if not empty raise an error.
    create_output_dir directory

    # Write meta.json file. Contains information about
    # the dump, format version etc.
    write_meta directory

    # Export structure
    dump_structure(cat, directory)

    # Export data
    dump_data(cat, directory)

    # Export references
    dump_references(cat, directory)

    # Dump files
    dump_files(cat, directory)
  end

  def dump_structure(cat, dir)
    # Create database
    File.write(File.join(dir, 'structure.sql'), dump_create_database(cat))

    # ItemsTypes become tables, ItemType fields become columns
    creates = render_header_comment("CREATE TABLE statements")
    # ItemTypes with no fields can't be created as a table with no columns
    creates << render_comment("Regular tables ==> single fields of ItemTypes")
    cat.item_types.select { |it| it.fields.count.positive? }.each do |it|
      creates << dump_create_item_types_table(it)
    end

    creates << render_comment("Additional tables ==> multiple reference fields of ItemTypes")
    cat.item_types.select { |it| it.fields.count.positive? }.each do |it|
      creates << dump_create_multiple_reference_table(it)
    end

    creates << render_comment("Additional tables ==> ChoiceSets")
    cat.choice_sets.each do |choice_set|
      creates << dump_create_choice_sets_table(choice_set)
    end

    creates << render_comment("Additional tables ==> Categories")
    cat.categories.each do |category|
      creates << dump_create_categories_table(category)
    end

    File.open(File.join(dir, 'structure.sql'), 'a+') { |f| f << creates }
  end

  def dump_data(cat, dir)
    File.write(File.join(dir, 'data.sql'), '')

    inserts = render_header_comment("INSERT INTO statements")

    # ItemsTypes become tables, ItemType fields become columns
    inserts << render_comment("Fields: single")
    cat.items.each do |item|
      fields = item.item_type.fields.reject(&:multiple)

      common_fields = COMMON_SQL_COLUMNS.map { |column_name, _column_type| "`#{column_name}`" }.join(',')
      common_fields << ', ' if fields.count.positive?

      column_names = common_fields << fields.map { |f| "`#{f.sql_slug}`" }.join(',')

      inserts << insert_into(item.item_type.sql_slug, column_names, concat_item_data(item))
    end

    inserts << render_comment("Fields: multiple")
    cat.items.each do |item|
      inserts << dump_mulitple_field_item_data(item)
    end

    inserts << render_comment("Choices")
    inserts << dump_choices_data(cat)

    inserts << render_footer_comment
    File.open(File.join(dir, 'data.sql'), 'a+') { |f| f << inserts }
  end

  def dump_references(cat, dir)
    # struct_dir = File.join(dir, 'structure')

    File.write(File.join(dir, 'references.sql'), '')

    # Export primary keys
    alters = render_header_comment("PRIMARY KEYS")
    alters << dump_primary_keys(cat)

    alters << render_header_comment("REFERENCES")
    alters << dump_single_references_and_choices(cat)

    alters << render_comment("Multiple references")
    alters << dump_multiple_references_and_choices(cat)

    File.open(File.join(dir, 'references.sql'), 'a+') { |f| f << alters }
  end

  private

  def dump_create_database(cat)
    "CREATE DATABASE `#{cat.sql_slug}`;\n\n"
  end

  def dump_create_item_types_table(item_type)
    columns = common_sql_columns

    fields = item_type.fields.reject(&:multiple)
    fields.each do |field|
      columns << "`#{field.sql_slug}` #{field.sql_type} #{field.sql_nullable} #{field.sql_default} #{field.sql_unique},"
    end

    create_table(item_type.sql_slug, columns)
  end

  def dump_create_multiple_reference_table(item_type)
    tables = ""
    item_type.fields.select { |f| f.multiple? && f.is_a?(Field::Reference) }.each do |field|
      primary_field = item_type.primary_field
      # References that point to a multiple field dont't have the primary field column so we force it to id
      # foreign_column_name = 'id' if item_type.primary_field.multiple?

      columns = "`#{item_type.sql_slug}` #{convert_app_type_to_sql_type(primary_field)},"
      column_name = "#{field.sql_slug}_#{field.related_item_type.sql_slug}"
      columns << "`#{column_name}` #{convert_app_type_to_sql_type(field.related_item_type.primary_field)}"

      tables << create_table(field.sql_slug, columns)
    end

    tables
  end

  def dump_create_choice_sets_table(choice_set)
    columns = ""

    Choice.columns_hash.each do |col_name, col|
      columns << "`#{col_name}` #{convert_active_storage_type_to_sql_type(col.type)} #{'NOT NULL' unless col.null},"
    end

    create_table(choice_set.name, columns)
  end

  def dump_create_categories_table(category)
    columns = ""

    Category.columns_hash.each do |col_name, col|
      columns << "`#{col_name}` #{convert_active_storage_type_to_sql_type(col.type)} #{'NOT NULL' unless col.null},"
    end

    category.fields.each do |field|
      columns << "`#{field.sql_slug}` #{field.sql_type} #{field.sql_nullable} #{field.sql_default} #{field.sql_unique},"
    end

    create_table(category.name, columns)
  end

  def concat_item_data(item)
    values = ""

    values << "#{item.id},"
    values << "#{convert_active_storage_value_to_sql_value(:datetime, item.created_at)},"
    values << "#{convert_active_storage_value_to_sql_value(:datetime, item.updated_at)},"

    item.fields.each do |field|
      # ManyToMany references have separate tables
      next if field.multiple?

      values << "#{sql_value(field, item)},"
    end

    remove_ending_comma!(values)
  end

  def dump_mulitple_field_item_data(item)
    inserts = ""

    fields = item.item_type.fields.select { |field| field.multiple? && field.is_a?(Field::Reference) }
    fields.each do |field|
      value = if item.item_type.primary_field.nil? ||
                 item.item_type.primary_field&.is_a?(Field::Reference) ||
                 item.item_type.primary_field&.is_a?(Field::ChoiceSet)
                item.id
              else
                "'#{item.item_type.primary_field&.value_for_item(item)}'"
              end

      next if value == "''"

      field.value_for_item(item).each do |_ref|
        columns = "`#{item.item_type.sql_slug}`, `#{field.sql_slug}_#{field.related_item_type.sql_slug}`"
        values = "#{value}, #{field.related_item_type.id}"
        inserts << insert_into(field.sql_slug, columns, values)
      end
    end

    inserts
  end

  def dump_choices_data(cat)
    inserts = ""
    cat.choice_sets.each do |choice_set|
      choice_set.choices.each do |choice|
        columns = Choice.columns_hash.map { |c_name, _c| "`#{c_name}`" }.join(',')

        values = ""
        Choice.columns_hash.each do |column_name, column|
          value = convert_active_storage_value_to_sql_value(column.type, choice.public_send(column_name))
          values << "#{value}#{', ' unless column_name == Choice.columns_hash.keys.last}"
        end

        insert_template = insert_into(choice.choice_set.name, columns, values)
        inserts << insert_template
      end
    end

    inserts
  end

  def dump_primary_keys(cat)
    alters = render_comment("ITEMS")
    cat.items.each do |item|
      alter = add_primary_key(item.item_type.sql_slug, primary_key(item.item_type))

      alters << alter unless alters.include?(alter)
    end

    # Primary keys on intermediate tables are not needed
    # alters << render_comment("FIELDS multiple:true")
    # cat.items.each do |item|
    #   item.fields.select { |f| f.multiple? && f.is_a?(Field::Reference) }.each do |field|
    #     alter = add_primary_key(field.sql_slug, "#{item.item_type.sql_slug}`, `#{field.sql_slug}_#{field.related_item_type.sql_slug}")
    #
    #     alters << alter unless alters.include?(alter)
    #   end
    # end

    alters << render_comment("CHOICE SETS")
    cat.choice_sets.each do |choice_set|
      alters << add_primary_key(choice_set.name, "id")
    end

    alters << render_comment("CATEGORIES")
    cat.categories.each do |category|
      primary_field = category.fields.select(&:primary?).first
      alters << add_primary_key(category.name, primary_field&.sql_slug.presence || 'id')
    end

    alters << render_footer_comment
  end

  def dump_single_references_and_choices(cat)
    alters = render_comment("Single references")
    cat.items.each do |item|
      # Single references and choices
      fields = item.item_type.fields.select { |field| !field.multiple? && field.is_a?(Field::Reference) }
      fields.each do |field|
        related_primary_field = field.related_item_type.primary_field
        foreign_column_name = related_primary_field&.sql_slug.presence || 'id'
        # References that point to a multiple field dont't have the primary field column so we force it to id
        foreign_column_name = 'id' if field.related_item_type.primary_field.multiple?

        alter = add_foreign_key(
          item.item_type.sql_slug, field.sql_slug, field.related_item_type.sql_slug, foreign_column_name
        )
        alters << alter unless alters.include?(alter)
      end
    end

    alters
  end

  def dump_multiple_references_and_choices(cat)
    alters = render_comment("Mulitple references")
    cat.items.each do |item|
      # Multiple references and choices
      fields = item.item_type.fields.select { |field| field.multiple? && field.is_a?(Field::Reference) }
      fields.each do |field|
        primary_field = item.item_type.primary_field
        foreign_column_name = primary_field&.sql_slug.presence || 'id'
        # References that point to a multiple field dont't have the primary field column so we force it to id
        foreign_column_name = 'id' if item.item_type.primary_field.multiple?

        alter = add_foreign_key(
          field.sql_slug, item.item_type.sql_slug, item.item_type.sql_slug, foreign_column_name
        )
        alters << alter unless alters.include?(alter)
      end
    end

    alters
  end

  def primary_key(item_type)
    primary_field = item_type.primary_field
    # Primary keys that are multiple don't exist in the newly created table so the primary key becomes `id`
    primary_key = if primary_field.nil? || (primary_field.present? && primary_field.multiple?)
                    'id'
                  else
                    primary_field&.sql_slug
                  end

    primary_key
  end

  def common_sql_columns
    columns = ""

    COMMON_SQL_COLUMNS.each do |column_name, column_type|
      columns << "`#{column_name}` #{column_type} NOT NULL,"
    end

    columns
  end

  def convert_active_storage_type_to_sql_type(type)
    case type
    when :string
      "VARCHAR(255)"
    when :integer
      "INT"
    when :json
      "JSON"
    when :datetime
      "TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
    else
      "VARCHAR(255)"
    end
  end

  def convert_app_type_to_sql_type(field)
    return "INT" if field.nil?

    case field.type
    when "Field::Boolean"
      "BOOLEAN"
    when "Field::Int", "Field::ChoiceSet", "Field::Reference"
      "INT"
    when "Field::DateTime"
      "JSON"
    when "Field::Decimal"
      "FLOAT"
    # when :datetime
    #   "TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
    else
      "VARCHAR(255)"
    end
  end

  def convert_active_storage_value_to_sql_value(type, value)
    return "NULL" if value.blank?

    case type
    # when :string
    #   "VARCHAR(255)"
    when :integer
      value
    when :json
      "'#{value.to_json.to_s.gsub("'") { "\\'" }}'"
    when :datetime
      "'#{value.utc.to_s.gsub(' UTC', '')}'"
    else
      value = value.gsub("'") { "\\'" }
      "'#{value}'"
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def sql_value(field, item)
    value = field.value_for_item(item)
    return "NULL" if value.blank?

    case field.type
    when "Field::Int", "Field::Decimal", "Field::Editor"
      value
    when "Field::Reference", "Field::ChoiceSet"
      # The value of the field is not necessarily the id for a reference
      if field.is_a?(Field::Reference) && !field.related_item_type.primary_field.is_a?(Field::Reference)
        item = Item.find_by(:id => item.data[field.uuid])
        return sql_value(field.related_item_type.primary_field, item)
      end

      value.id
    when "Field::Boolean"
      value == "0" ? "FALSE" : "TRUE"
    when "Field::DateTime", "Field::Geometry"
      "'#{value.to_json}'"
    else
      "'#{value.to_s.gsub("'") { "\\'" }}'"
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
# rubocop:enable Metrics/ClassLength
