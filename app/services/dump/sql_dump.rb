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
    @holder = SqlExport::Holder.new
  end

  def dump(catalog, directory)
    cat = Catalog.find_by(slug: catalog)
    raise "ERROR. Catalog '#{catalog}' not found." if cat.nil?

    # Check if directory exists; create if necessary,
    # if not empty raise an error.
    create_output_dir directory unless File.directory?(directory)

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

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def dump_structure(cat, dir)
    # Create database
    File.write(File.join(dir, @holder.dump_file_name(cat)), '')

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

    creates << render_comment("Additional tables ==> multiple choicesets fields of ItemTypes")
    cat.item_types.select { |it| it.fields.count.positive? }.each do |it|
      creates << dump_create_multiple_choiceset_table(it)
    end

    creates << render_comment("Additional tables ==> ChoiceSets")
    cat.choice_sets.each do |choice_set|
      creates << dump_create_choice_sets_table(choice_set)
    end

    creates << render_comment("Additional tables ==> Categories")
    cat.categories.each do |category|
      creates << dump_create_categories_table(category)
    end

    creates << render_comment("Additional tables ==> multiple references fields of Categories")
    cat.categories.each do |category|
      creates << dump_create_multiple_category_reference_table(category)
    end

    creates << render_comment("Additional tables ==> multiple choicesets fields of Categories")
    cat.categories.each do |category|
      creates << dump_create_multiple_category_choiceset_table(category)
    end

    File.open(File.join(dir, @holder.dump_file_name(cat)), 'a+') { |f| f << creates }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def dump_data(cat, dir)
    inserts = render_header_comment("INSERT INTO statements")

    # ItemsTypes become tables, ItemType fields become columns
    inserts << render_comment("Fields: single and multiple non ref fields")
    inserts << dump_fields_data(cat)

    inserts << render_comment("Fields: Categories")
    inserts << dump_categories_data(cat)

    inserts << render_comment("Fields: multiple references")
    cat.items.find_each do |item|
      inserts << dump_mulitple_field_reference_item_data(item)
    end

    inserts << render_comment("Fields: multiple choicesets")
    cat.items.find_each do |item|
      inserts << dump_mulitple_field_choiceset_item_data(item)
    end

    inserts << render_comment("Choices")
    inserts << dump_choices_data(cat)

    inserts << render_footer_comment
    File.open(File.join(dir, @holder.dump_file_name(cat)), 'a+') { |f| f << inserts }
  end

  def dump_references(cat, dir)
    # Export primary keys
    alters = render_header_comment("PRIMARY KEYS")
    alters << dump_primary_keys(cat)

    alters << render_header_comment("REFERENCES")
    alters << dump_single_references(cat)

    alters << render_header_comment("CHOICES")
    alters << dump_single_choices(cat)

    alters << render_header_comment("CATEGORY REFERENCES")
    alters << dump_category_single_references(cat)

    alters << render_header_comment("CATEGORY CHOICES")
    alters << dump_category_single_choices(cat)

    alters << render_header_comment("MULTIPLE REFERENCES")
    alters << dump_references_multiple_reference(cat)

    alters << render_header_comment("CATEGORY MULTIPLE REFERENCES")
    alters << dump_category_references_multiple_reference(cat)

    alters << render_header_comment("MULTIPLE CHOICESET")
    alters << dump_references_multiple_choiceset(cat)

    alters << render_header_comment("CATEGORY MULTIPLE CHOICESET")
    alters << dump_category_references_multiple_choiceset(cat)

    File.open(File.join(dir, @holder.dump_file_name(cat)), 'a+') { |f| f << alters }
  end

  private

  def dump_create_item_types_table(item_type)
    columns = common_sql_columns

    fields = item_type.fields.reject { |f| f.multiple? && (f.is_a?(Field::Reference) || f.is_a?(Field::ChoiceSet)) }
    fields.each do |field|
      columns << "`#{field.sql_slug}` #{field.sql_type} #{field.sql_nullable} #{field.sql_default} #{field.sql_unique},"
    end
    # Save the custom primary key if any
    columns << "`primary_field` VARCHAR(255) NOT NULL DEFAULT '#{item_type.primary_field.slug}'" unless item_type.primary_field.nil?

    table_name = @holder.guess_table_name(item_type, "sql_slug")
    create_table(table_name, columns)
  end

  def dump_create_multiple_reference_table(item_type)
    tables = ""
    item_type.all_fields.select { |f| f.multiple? && f.is_a?(Field::Reference) }.each do |field|
      columns = "`#{item_type.sql_slug}` #{convert_app_type_to_sql_type(nil)},"
      column_name = "#{field.sql_slug}_#{field.related_item_type.sql_slug}"
      columns << "`#{column_name}` #{convert_app_type_to_sql_type(nil)}"

      table_name = @holder.guess_table_name(field, "sql_slug")
      tables << create_table(table_name, columns)
    end

    tables
  end

  def dump_create_multiple_choiceset_table(item_type)
    tables = ""
    item_type.fields.select { |f| f.multiple? && f.is_a?(Field::ChoiceSet) }.each do |field|
      columns = "`#{item_type.sql_slug}` #{convert_app_type_to_sql_type(nil)}, "
      columns << "`#{field.sql_slug}` #{convert_app_type_to_sql_type(nil)}"

      table_name = @holder.guess_table_name(field, "sql_slug")
      tables << create_table(table_name, columns)
    end

    tables
  end

  def dump_create_choice_sets_table(choice_set)
    columns = ""

    Choice.sql_columns.each do |col_name, col|
      columns << "`#{col_name}` #{convert_active_storage_type_to_sql_type(col.type)} #{'NOT NULL' unless col.null},"
    end

    table_name = @holder.guess_table_name(choice_set, "name")
    create_table(table_name, columns)
  end

  def dump_create_categories_table(category)
    columns = ""

    Category.columns_hash.each do |col_name, col|
      next unless %w[id created_at updated_at].include?(col_name)

      columns << "`#{col_name}` #{convert_active_storage_type_to_sql_type(col.type)} #{'NOT NULL' unless col.null},"
    end

    fields = category.fields.reject { |f| f.multiple? && (f.is_a?(Field::Reference) || f.is_a?(Field::ChoiceSet)) }
    fields.each do |field|
      columns << "`#{field.sql_slug}` #{field.sql_type} #{field.sql_nullable} #{field.sql_default} #{field.sql_unique},"
    end

    table_name = @holder.guess_table_name(category, "name")
    create_table(table_name, columns)
  end

  def dump_create_multiple_category_reference_table(category)
    tables = ""
    category.fields.select { |f| f.multiple? && f.is_a?(Field::Reference) }.each do |field|
      one_referenced_item = Item.where("data->>'#{field.uuid}' IS NOT NULL").first
      next if one_referenced_item.nil?

      columns = "`#{one_referenced_item.item_type.slug}` #{convert_app_type_to_sql_type(nil)},"
      column_name = "#{field.sql_slug}_#{field.related_item_type.sql_slug}"
      columns << "`#{column_name}` #{convert_app_type_to_sql_type(nil)}"

      table_name = @holder.guess_table_name(field, "sql_slug")
      tables << create_table(table_name, columns)
    end

    tables
  end

  def dump_create_multiple_category_choiceset_table(category)
    tables = ""
    category.fields.select { |f| f.multiple? && f.is_a?(Field::ChoiceSet) }.each do |field|
      one_referenced_item = Item.where("data->>'#{field.uuid}' IS NOT NULL").first
      next if one_referenced_item.nil?

      columns = "`#{one_referenced_item.item_type.slug}` #{convert_app_type_to_sql_type(nil)},"
      columns << "`#{field.sql_slug}` #{convert_app_type_to_sql_type(nil)}"

      table_name = @holder.guess_table_name(field, "sql_slug")
      tables << create_table(table_name, columns)
    end

    tables
  end

  def concat_item_data(item)
    values = ""

    values << "#{item.id},"
    values << "#{convert_active_storage_value_to_sql_value(:datetime, item.created_at)},"
    values << "#{convert_active_storage_value_to_sql_value(:datetime, item.updated_at)},"
    values << "'#{item.primary_field.sql_slug}'," unless item.primary_field.nil?

    item.fields.each do |field|
      # ManyToMany references have separate tables
      next if field.multiple? && (field.is_a?(Field::Reference) || field.is_a?(Field::ChoiceSet))

      values << "#{sql_value(field, item)},"
    end

    remove_ending_comma!(values)
  end

  def dump_mulitple_field_reference_item_data(item)
    return "" unless item.item_type.active?

    inserts = ""

    fields = item.item_type.all_fields.select { |field| field.multiple? && field.is_a?(Field::Reference) }
    fields.each do |field|
      # Rule: the primary key is always the id
      value = item.id

      next if value == "''"

      field.value_for_item(item).each do |ref|
        columns = "`#{item.item_type.sql_slug}`, `#{field.sql_slug}_#{field.related_item_type.sql_slug}`"
        values = "#{value}, #{ref.id}"
        insert_statement = insert_into(@holder.table_name(field, "sql_slug"), columns, values)

        inserts << insert_statement unless inserts.include?(insert_statement)
      end
    end

    inserts
  end

  def dump_mulitple_field_choiceset_item_data(item)
    inserts = ""

    fields = item.item_type.all_fields.select { |field| field.multiple? && field.is_a?(Field::ChoiceSet) }
    fields.each do |field|
      next unless item.item_type.active?

      # Rule: the primary key is always the id
      value = item.id
      next if value == "''"

      field.value_for_item(item).each do |ref|
        columns = "`#{item.item_type.sql_slug}`, `#{field.sql_slug}`"
        values = "#{value}, #{ref.id}"
        insert_statement = insert_into(@holder.table_name(field, "sql_slug"), columns, values)

        inserts << insert_statement unless inserts.include?(insert_statement)
      end
    end

    inserts
  end

  def dump_choices_data(cat)
    inserts = ""
    cat.choice_sets.each do |choice_set|
      choice_set_inserts = ""
      choice_set.choices.each do |choice|
        columns = Choice.sql_columns.map { |c_name, _c| "`#{c_name}`" }.join(',')

        values = ""
        Choice.sql_columns.each do |column_name, column|
          value = convert_active_storage_value_to_sql_value(column.type, choice.public_send(column_name))
          values << "#{value}#{', ' unless column_name == Choice.columns_hash.keys.last}"
        end

        insert_template = insert_into(@holder.table_name(choice_set, "name"), columns, values)
        choice_set_inserts << insert_template
      end
      inserts << choice_set_inserts
    end

    inserts
  end

  def dump_fields_data(cat)
    inserts = ""
    cat.items.find_each do |item|
      next unless item.item_type.active?

      fields = item.item_type.fields.reject { |f| f.multiple? && (f.is_a?(Field::Reference) || f.is_a?(Field::ChoiceSet)) }

      common_fields = COMMON_SQL_COLUMNS.map { |column_name, _column_type| "`#{column_name}`" }.join(',')
      common_fields << ", `primary_field`" if item.primary_field.present?
      common_fields << ", " if fields.count.positive?

      column_names = common_fields << fields.map { |f| "`#{f.sql_slug}`" }.join(',')

      inserts << insert_into(@holder.table_name(item.item_type, "sql_slug"), column_names, concat_item_data(item))
    end

    inserts
  end

  # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
  def dump_categories_data(cat)
    inserts = ""
    categories_processed_by_item = {}
    cat.items.find_each do |item|
      cat.categories.each do |category|
        fields = category.fields.reject { |f| f.multiple? && (f.is_a?(Field::Reference) || f.is_a?(Field::ChoiceSet)) }
        fields.each do |field|
          next if item.data[field.uuid].nil? || (categories_processed_by_item[item.id].present? && categories_processed_by_item[item.id].include?(category.id))

          column_names = '`id`, '
          column_names << fields.map { |f| "`#{f.sql_slug}`" }.join(',')

          values = "#{item.id}, "
          fields.each { |f| values << "#{sql_value(f, item)}," }

          remove_ending_comma!(values)

          inserts << insert_into(@holder.table_name(category, "name"), column_names, values)

          if categories_processed_by_item[item.id].present?
            categories_processed_by_item[item.id] << category.id
          else
            categories_processed_by_item[item.id] = [category.id]
          end
        end

        next unless category.fields.count != fields.count && fields.count.zero?

        column_names = '`id`'
        values = item.id.to_s

        inserts << insert_into(@holder.table_name(category, "name"), column_names, values)

        if categories_processed_by_item[item.id].present?
          categories_processed_by_item[item.id] << category.id
        else
          categories_processed_by_item[item.id] = [category.id]
        end
      end
    end

    inserts
  end
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength

  def dump_primary_keys(cat)
    alters = render_comment("ITEMS")
    cat.items.find_each do |item|
      next unless item.item_type.active?

      # constraint = primary_key_constraint(item.item_type)
      alter = add_primary_key(@holder.table_name(item.item_type, "sql_slug"), primary_key(item.item_type))

      alters << alter unless alters.include?(alter)
    end

    alters << render_comment("CHOICE SETS")
    cat.choice_sets.each do |choice_set|
      alters << add_primary_key(@holder.table_name(choice_set, "name"), "id")
    end

    alters << render_comment("CATEGORIES")
    cat.categories.each do |category|
      alters << add_primary_key(@holder.table_name(category, "name"), 'id')
    end

    alters << render_footer_comment
  end

  def dump_single_references(cat)
    alters = render_comment("Single references")
    cat.items.find_each do |item|
      next unless item.item_type.active?

      # Single references and choices
      fields = item.item_type.fields.select { |field| !field.multiple? && field.is_a?(Field::Reference) }
      fields.each do |field|
        foreign_column_name = 'id'

        table_name = @holder.table_name(item.item_type, "sql_slug")
        related_table_name = @holder.table_name(field.related_item_type, "sql_slug")
        alter = add_foreign_key(table_name, field.sql_slug, related_table_name, foreign_column_name)
        alters << alter unless alters.include?(alter)
      end
    end

    alters
  end

  def dump_single_choices(cat)
    alters = render_comment("Single choices")
    cat.items.find_each do |item|
      next unless item.item_type.active?

      # Single references and choices
      fields = item.item_type.fields.select { |field| !field.multiple? && field.is_a?(Field::ChoiceSet) }
      fields.each do |field|
        foreign_column_name = 'id'

        table_name = @holder.table_name(item.item_type, "sql_slug")
        related_table_name = @holder.table_name(field.choice_set, "name")
        alter = add_foreign_key(table_name, field.sql_slug, related_table_name, foreign_column_name)
        alters << alter unless alters.include?(alter)
      end
    end

    alters
  end

  def dump_category_single_references(cat)
    alters = render_comment("Single references for categories")
    cat.categories.each do |category|
      # Single references and choices
      fields = category.fields.select { |field| !field.multiple? && field.is_a?(Field::Reference) }
      fields.each do |field|
        foreign_column_name = 'id'

        category = Category.find_by(id: field.category_id)
        table_name = @holder.table_name(category, "name")
        related_table_name = @holder.table_name(field.related_item_type, "sql_slug")
        alter = add_foreign_key(table_name, field.sql_slug, related_table_name, foreign_column_name)
        alters << alter unless alters.include?(alter)
      end
    end

    alters
  end

  def dump_category_single_choices(cat)
    alters = render_comment("Single choices for categories")

    cat.categories.each do |category|
      # Single references and choices
      fields = category.fields.select { |field| !field.multiple? && field.is_a?(Field::ChoiceSet) }
      fields.each do |field|
        foreign_column_name = 'id'

        category = Category.find_by(id: field.category_id)
        table_name = @holder.table_name(category, "name")
        related_table_name = @holder.table_name(field.choice_set, "name")
        alter = add_foreign_key(table_name, field.sql_slug, related_table_name, foreign_column_name)
        alters << alter unless alters.include?(alter)
      end
    end

    alters
  end

  def dump_references_multiple_reference(cat)
    alters = render_comment("Mulitple references")
    cat.items.find_each do |item|
      next unless item.item_type.active?

      # Multiple references
      fields = item.item_type.fields.select { |field| field.multiple? && field.is_a?(Field::Reference) }
      fields.each do |field|
        foreign_column_name = 'id'

        table_name = @holder.table_name(field, "sql_slug")
        related_table_name = @holder.table_name(item.item_type, "sql_slug")
        related_item_type_table_name = @holder.table_name(field.related_item_type, "sql_slug")
        alter = add_foreign_key(
          table_name, item.item_type.sql_slug, related_table_name, foreign_column_name
        )
        alter2 = add_foreign_key(
          table_name, "#{field.sql_slug}_#{field.related_item_type.sql_slug}", related_item_type_table_name, foreign_column_name
        )

        alters << alter unless alters.include?(alter)
        alters << alter2 unless alters.include?(alter2)
      end
    end

    alters
  end

  def dump_category_references_multiple_reference(cat)
    alters = render_comment("Mulitple references for categories")
    cat.categories.each do |category|
      # Multiple references
      fields = category.fields.select { |field| field.multiple? && field.is_a?(Field::Reference) }
      fields.each do |field|
        foreign_column_name = "id"

        # Manually find an Item using this field
        item = Item.where("data->>'#{field.uuid}' IS NOT NULL").first
        next if item.nil?

        table_name = @holder.table_name(field, "sql_slug")
        related_table_name = @holder.table_name(category, "name")
        related_item_type_table_name = @holder.table_name(field.related_item_type, "sql_slug")
        alter = add_foreign_key(
          table_name, item.item_type.sql_slug, related_table_name, foreign_column_name
        )
        alter2 = add_foreign_key(
          table_name, "#{field.sql_slug}_#{field.related_item_type.sql_slug}", related_item_type_table_name, foreign_column_name
        )
        alters << alter unless alters.include?(alter)
        alters << alter2 unless alters.include?(alter2)
      end
    end

    alters
  end

  def dump_references_multiple_choiceset(cat)
    alters = render_comment("Mulitple choicesets")
    cat.items.find_each do |item|
      next unless item.item_type.active?

      # Multiple choices
      fields = item.item_type.fields.select { |field| field.multiple? && field.is_a?(Field::ChoiceSet) }
      fields.each do |field|
        foreign_column_name = 'id'

        table_name = @holder.table_name(field, "sql_slug")
        related_table_name = @holder.table_name(item.item_type, "sql_slug")
        choiceset_table_name = @holder.table_name(field.choice_set, "name")
        alter = add_foreign_key(table_name, item.item_type.sql_slug, related_table_name, foreign_column_name)
        alter2 = add_foreign_key(table_name, field.sql_slug, choiceset_table_name, foreign_column_name)

        alters << alter unless alters.include?(alter)
        alters << alter2 unless alters.include?(alter2)
      end
    end

    alters
  end

  def dump_category_references_multiple_choiceset(cat)
    alters = render_comment("Mulitple choicesets for categories")
    cat.categories.each do |category|
      # Multiple choices
      fields = category.fields.select { |field| field.multiple? && field.is_a?(Field::ChoiceSet) }
      fields.each do |field|
        next unless field.item_type.active?

        foreign_column_name = 'id'

        # Manually find an Item using this field
        item = Item.where("data->>'#{field.uuid}' IS NOT NULL").first
        table_name = @holder.table_name(field, "sql_slug")
        related_table_name = @holder.table_name(category, "name")
        choiceset_table_name = @holder.table_name(field.choice_set, "name")
        alter = add_foreign_key(table_name, item.item_type.sql_slug, related_table_name, foreign_column_name)
        alter2 = add_foreign_key(table_name, field.sql_slug, choiceset_table_name, foreign_column_name)

        alters << alter unless alters.include?(alter)
        alters << alter2 unless alters.include?(alter2)
      end
    end

    alters
  end

  def primary_key(_item_type)
    "id"
  end

  def primary_key_constraint(item_type)
    return nil if item_type.nil?

    primary_field = item_type.primary_field
    return nil if primary_field.nil? || primary_field.multiple? || !primary_field.is_a?(Field::Text)

    256
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
      "DOUBLE"
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
      "'#{value.to_json.to_s.gsub("'") { "\\'" }.gsub('\\t') { 't' }.gsub('"') { '\\"' }}'"
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
    return "NULL" if value.blank? && field.type != "Field::Editor"

    case field.type
    when "Field::Int", "Field::Decimal"
      value
    when "Field::Reference", "Field::ChoiceSet"
      value.id
    when "Field::Boolean"
      value == "0" ? "FALSE" : "TRUE"
    when "Field::DateTime"
      "'#{value.to_json}'"
    when "Field::Geometry", "Field::File", "Field::Image", "Field::Text"
      "'#{field.sql_value(item)}'"
    when "Field::Editor"
      "'#{field.field_value_for_item(item)}'"
    else
      "'#{value.to_s.gsub("'") { "\\'" }}'"
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
# rubocop:enable Metrics/ClassLength
