require 'fileutils'

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
    # create_output_dir directory

    # Write meta.json file. Contains information about
    # the dump, format version etc.
    # write_meta directory

    # Export structure
    dump_structure(cat, directory)

    # Export data
    dump_data(cat, directory)

    # Export references
    dump_references(cat, directory)

    # TODO : Dump files
  end

  def dump_structure(cat, dir)
    # struct_dir = File.join(dir, 'structure')
    # Dir.mkdir struct_dir

    # Create database
    File.write(File.join(dir, 'structure.sql'), dump_create_database(cat))

    # ItemsTypes become tables, ItemType fields become columns
    tables = ""
    cat.item_types.select { |it| it.fields.count.positive? }.each do |it|
      tables << dump_create_item_types_table(it)
      tables << dump_create_reference_table(it)
    end

    # ChoiceSets become tables, Choices become columns
    cat.choice_sets.each do |choice_set|
      tables << dump_create_choice_sets_table(choice_set)
    end

    cat.categories.each do |category|
      tables << dump_create_categories_table(category)
    end

    File.open(File.join(dir, 'structure.sql'), 'a+') { |f| f << tables }
  end


  def dump_data(cat, dir)
    # struct_dir = File.join(dir, 'structure')

    File.write(File.join(dir, 'data.sql'), '')

    # ItemsTypes become tables, ItemType fields become columns
    inserts = ""
    cat.items.each do |item|
      common_fields = COMMON_SQL_COLUMNS.map { |column_name, _column_type| "`#{column_name}`" }.join(',')
      fields = item.item_type.fields.reject(&:multiple)

      inserts << "INSERT INTO `#{item.item_type.sql_slug}` (#{common_fields} #{',' if fields.count.positive?} #{fields.map { |f| "`#{f.sql_slug}`"}.join(',')}) VALUES (\n#{dump_item_data(item)});\n\n"

      fields = item.item_type.fields.select { |field| field.multiple? && field.is_a?(Field::Reference) }
      fields.each do |field|
        value = if item.item_type.primary_field.nil? || item.item_type.primary_field&.is_a?(Field::Reference) || item.item_type.primary_field&.is_a?(Field::ChoiceSet)
                  item.id
                else
                  # "'#{field.field_value_for_item(item)}'"
                  "'#{item.item_type.primary_field&.value_for_item(item)}'"
                end

        next if value == "''"

        field.value_for_item(item).each do |ref|
          inserts << "INSERT INTO `#{field.sql_slug}` (`#{item.item_type.sql_slug}`, `#{field.sql_slug}_#{field.related_item_type.sql_slug}`) VALUES (\n#{value}, #{field.related_item_type.id});\n\n"
        end
      end
    end

    inserts << dump_choices_data(cat, dir)

    File.open(File.join(dir, 'data.sql'), 'a+') { |f| f << inserts }
  end

  def dump_primary_keys(cat)
    alters = render_header_comment("PRIMARY KEYS")
    alters << render_comment("ITEMS")
    cat.items.each do |item|
      alter = "ALTER TABLE `#{item.item_type.sql_slug}` ADD #{primary_key(item.item_type)};\n"

      alters << alter unless alters.include?(alter)
    end

    alters << render_comment("FIELDS multiple:true")
    cat.items.each do |item|
      # TODO: #{field.sql_slug}_#{field.related_item_type.sql_slug} can be too long...
      item.fields.select { |f| f.multiple? && f.is_a?(Field::Reference) }.each do |field|
        alter = "-- ALTER TABLE `#{field.sql_slug}` ADD PRIMARY KEY (`#{item.item_type.sql_slug}`, `#{field.sql_slug}_#{field.related_item_type.sql_slug}`);\n"

        alters << alter unless alters.include?(alter)
      end
    end

    alters << render_comment("CHOICE SETS")
    cat.choice_sets.each do |choice_set|
      alters << "ALTER TABLE `#{choice_set.name}` ADD PRIMARY KEY (`id`);\n"
    end

    alters << render_comment("CATEGORIES")
    cat.categories.each do |category|
      primary_field = category.fields.select(&:primary?).first
      alters << if primary_field.present?
                  "ALTER TABLE `#{category.name}` ADD PRIMARY KEY (`#{primary_field.sql_slug}`);\n"
                else
                  "ALTER TABLE `#{category.name}` ADD PRIMARY KEY (`id`);\n"
                end
    end

    alters << render_footer_comment
    alters
  end

  def dump_references(cat, dir)
    # struct_dir = File.join(dir, 'structure')

    File.write(File.join(dir, 'references.sql'), '')

    # Export primary keys
    alters = dump_primary_keys(cat)

    alters << render_header_comment("REFERENCES")
    alters << render_comment("Single references")
    cat.items.each do |item|
      # Single references and choices
      fields = item.item_type.fields.select { |field| !field.multiple? && field.is_a?(Field::Reference) }
      fields.each do |field|
        # alter = "ALTER TABLE `#{item.item_type.sql_slug}` ADD #{primary_key(item.item_type)};\n"

        related_primary_field = field.related_item_type.primary_field
        foreign_column_name = related_primary_field&.sql_slug.presence || 'id'
        # References that point to a multiple field dont't have the primary field column so we force it to id
        foreign_column_name = 'id' if field.related_item_type.primary_field.multiple?

        alter = "ALTER TABLE `#{item.item_type.sql_slug}` ADD FOREIGN KEY (`#{field.sql_slug}`) REFERENCES `#{field.related_item_type.sql_slug}`(`#{foreign_column_name}`);\n\n"

        alters << alter unless alters.include?(alter)
      end
    end

    alters << render_comment("Multiple references")
    cat.items.each do |item|
      # Multiple references and choices
      fields = item.item_type.fields.select { |field| field.multiple? && field.is_a?(Field::Reference) }
      fields.each do |field|
        primary_field = item.item_type.primary_field
        foreign_column_name = primary_field&.sql_slug.presence || 'id'
        # References that point to a multiple field dont't have the primary field column so we force it to id
        foreign_column_name = 'id' if item.item_type.primary_field.multiple?

        alter = "ALTER TABLE `#{field.sql_slug}` ADD FOREIGN KEY (`#{item.item_type.sql_slug}`) REFERENCES `#{item.item_type.sql_slug}`(`#{foreign_column_name}`);\n\n"
        alters << alter unless alters.include?(alter)

        # TODO: on ne peut pas ajouter plusieurs références ?
        # alter = "ALTER TABLE `#{field.sql_slug}` ADD FOREIGN KEY (`#{field.sql_slug}_#{field.related_item_type.sql_slug}`) REFERENCES `#{field.related_item_type.sql_slug}`(`id`);\n\n"
        # alters << alter unless alters.include?(alter)
      end
    end

    File.open(File.join(dir, 'references.sql'), 'a+') { |f| f << alters }
  end


  def dump_choices_data(cat, dir)
    inserts = ""
    cat.choice_sets.each do |choice_set|
      choice_set.choices.each do |choice|
        insert_template = "INSERT INTO `#{choice.choice_set.name}` (#{Choice.columns_hash.map { |c_name, _c| "`#{c_name}`"}.join(',')}) VALUES (\n"
        Choice.columns_hash.each do |column_name, column|
          value = convert_active_storage_value_to_sql_value(column.type, choice.public_send(column_name))
          insert_template << "#{value}#{',' unless column_name == Choice.columns_hash.keys.last} \n"
        end
        insert_template << "\n);\n\n"

        inserts << insert_template
      end
    end

    inserts
  end

  def dump_create_database(cat)
    "CREATE DATABASE `#{cat.sql_slug}`; \n\n"
  end

  def dump_create_item_types_table(item_type)
    columns = common_sql_columns

    fields = item_type.fields.reject(&:multiple)
    fields.each do |field|
      columns << "`#{field.sql_slug}` #{field.sql_type} #{field.sql_nullable} #{field.sql_default} #{field.sql_unique}#{',' unless field == fields.last}"
    end

    columns.gsub!(/,$/, '')
    columns.gsub!(/,/, ",\n")

    "CREATE TABLE `#{item_type.sql_slug}` (\n#{columns}\n);\n\n"
  end

  def dump_create_reference_table(item_type)
    tables = ""
    item_type.fields.each do |field|
      # ManyToMany references have separate tables
      next unless field.multiple? && field.is_a?(Field::Reference)

      # TODO: create columns based on the primary fields
      primary_field = item_type.primary_field
      foreign_column_name = primary_field&.sql_slug.presence || 'id'
      # References that point to a multiple field dont't have the primary field column so we force it to id
      # foreign_column_name = 'id' if item_type.primary_field.multiple?

      columns = "`#{item_type.sql_slug}` #{convert_app_type_to_sql_type(primary_field)},\n"
      column_name = "#{field.sql_slug}_#{field.related_item_type.sql_slug}"
      columns << "`#{column_name}` #{convert_app_type_to_sql_type(field.related_item_type.primary_field)}\n"

      tables << "CREATE TABLE `#{field.sql_slug}` (\n#{columns}\n);\n\n"
    end

    tables
  end

  def dump_create_choice_sets_table(choice_set)
    columns = ""

    Choice.columns_hash.each do |column_name, column|
      columns << "`#{column_name}` #{convert_active_storage_type_to_sql_type(column.type)} #{'NOT NULL' unless column.null},"
    end

    columns.gsub!(/,$/, '')
    columns.gsub!(/,/, ",\n")

    "CREATE TABLE `#{choice_set.name}` (\n#{columns}\n);\n\n"
  end

  def dump_create_categories_table(category)
    columns = ""

    Category.columns_hash.each do |column_name, column|
      columns << "`#{column_name}` #{convert_active_storage_type_to_sql_type(column.type)} #{'NOT NULL' unless column.null},"
    end

    category.fields.each do |field|
      columns << "`#{field.sql_slug}` #{field.sql_type} #{field.sql_nullable} #{field.sql_default} #{field.sql_unique},"
    end

    columns.gsub!(/,$/, '')
    columns.gsub!(/,/, ",\n")

    "CREATE TABLE `#{category.name}` (\n#{columns}\n);\n\n"
  end

  def primary_key(item_type)
    primary_field = item_type.primary_field
    # Primary keys that are multiple should don't exist in the newly created table so the primary key becomes `id`
    primary_key = if primary_field.nil? || (primary_field.present? && primary_field.multiple?)
                    'id'
                  else
                    primary_field&.sql_slug
                  end

    "PRIMARY KEY (`#{primary_key}`)"
  end

  def dump_item_data(item)
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

  def dump_catalog_information(cat, struct_dir)
    cat_json = cat.as_json(only: [:slug, :name, :primary_language, :other_languages,
                                  :advertize, :requires_review]
                          )
    File.write(File.join(struct_dir, 'catalog.json'), JSON.pretty_generate(cat_json))
  end

  def dump_item_types_structure(cat, struct_dir)
    item_type_dir = File.join(struct_dir, 'item-types')
    Dir.mkdir item_type_dir
    cat.item_types.each do |it|
      dump_item_type_structure(it, item_type_dir)
    end
  end

  def dump_item_type_structure(it, dir)
    dmp = it.as_json(only: %i(slug name_translations name_plural_translations))
    dmp["fields"] = it.fields.map(&:describe)
    dmp['item-views'] = it.item_views.map(&:describe)
    File.write(File.join(dir, "#{it.sql_slug}.json"), JSON.pretty_generate(dmp))
  end

  def dump_categories(cat, struct_dir)
    File.write(
      File.join(struct_dir, 'categories.json'),
      JSON.pretty_generate("categories": cat.categories.map(&:describe))
    )
  end

  def dump_choice_sets(cat, struct_dir)
    File.write(
      File.join(struct_dir, 'choice-sets.json'),
      JSON.pretty_generate("choice-sets": cat.choice_sets.map(&:describe))
    )
  end

  private

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

  def sql_value(field, item)
    value = field.value_for_item(item)
    return "NULL" if value.blank?

    case field.type
    when "Field::Int", "Field::Decimal", "Field::Editor"
      value
    when "Field::Reference", "Field::ChoiceSet"
      # The value of the field is not necessarily the id for a reference
      if field.is_a?(Field::Reference) && field.related_item_type.primary_field.present? && !field.related_item_type.primary_field.is_a?(Field::Reference)
        # return sql_value(field.related_item_type.primary_field, item)
        # return "'#{item.data[field.uuid]}'"
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
end
