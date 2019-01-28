require 'fileutils'

class SqlDump
  COMMON_SQL_COLUMNS = {
    :id => "INT PRIMARY KEY",
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

    # Export data & files
    # dump_data(cat, directory)
    # dump_files(cat, directory)
    #
    # # Dump pages and menu items
    # dump_pages(cat, directory)
    # dump_menu_items(cat, directory)
  end

  def write_meta(dir)
    meta = { dump_created_at: Time.now.utc.to_s, dump_version: '1.0' }
    File.write(File.join(dir, 'meta.json'), JSON.pretty_generate(meta))
  end

  def create_output_dir(d)
    ensure_no_file_overwrite(d)
    ensure_empty_directory(d)
    FileUtils.mkdir_p(d) unless File.exist?(d)
  end

  def dump_structure(cat, dir)
    struct_dir = File.join(dir, 'structure')
    # Dir.mkdir struct_dir

    # Create database
    File.write(File.join(struct_dir, 'structure.sql'), dump_create_database(cat))

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

    File.open(File.join(struct_dir, 'structure.sql'), 'a+') { |f| f << tables }

    # Dump the catalog information
    # dump_catalog_information(cat, struct_dir)
    #
    # # Dump all the item types
    # dump_item_types_structure(cat, struct_dir)
    #
    # # Dump categories
    # dump_categories(cat, struct_dir)
    #
    # # Dump choice sets
    # dump_choice_sets(cat, struct_dir)
  end


  def dump_data(cat, dir)
    struct_dir = File.join(dir, 'structure')

    File.write(File.join(struct_dir, 'data.sql'), '')

    # ItemsTypes become tables, ItemType fields become columns
    inserts = ""
    cat.items.each do |item|
      common_fields = COMMON_SQL_COLUMNS.map { |column_name, _column_type| "`#{column_name}`" }.join(',')
      fields = item.item_type.fields.reject(&:multiple)

      inserts << "INSERT INTO `#{item.item_type.slug}` (#{common_fields}, #{fields.map { |f| "`#{f.slug}`"}.join(',')}) \n VALUES (#{dump_item_data(item)});\n\n"


      fields = item.item_type.fields.select { |field| field.multiple? && field.is_a?(Field::Reference) }
      fields.each do |field|
        inserts << "INSERT INTO `#{field.slug}` (`#{item.item_type.slug}`, `#{field.slug}_#{field.related_item_type.slug}`) \n VALUES (#{item.id}, #{field.related_item_type.id});\n\n"
      end
    end

    inserts << dump_choices_data(cat, dir)

    File.open(File.join(struct_dir, 'data.sql'), 'a+') { |f| f << inserts }
  end


  def dump_references(cat, dir)
    struct_dir = File.join(dir, 'structure')

    File.write(File.join(struct_dir, 'references.sql'), '')

    alters = ""
    cat.items.each do |item|
      # Todo: make sure id the correct primary key
      # Single references and choices
      fields = item.item_type.fields.select { |field| !field.multiple? && field.is_a?(Field::Reference) }
      fields.each do |field|
        alter = ""
        alter = "ALTER TABLE `#{item.item_type.slug}` ADD #{primary_key(item.item_type)};\n" if primary_key(item.item_type).present?
        alter << "ALTER TABLE `#{item.item_type.slug}` ADD FOREIGN KEY (`#{field.slug}`) \n REFERENCES `#{field.related_item_type.slug}`(`id`);\n\n"

        alters << alter unless alters.include?(alter)
      end

      # Multiple references and choices
      fields = item.item_type.fields.select { |field| field.multiple? && field.is_a?(Field::Reference) }
      fields.each do |field|
        alters << "ALTER TABLE `#{field.related_item_type.slug}` ADD FOREIGN KEY (`#{field.related_item_type.slug}`) \n REFERENCES(`#{field.slug}`);\n\n"
      end
    end

    File.open(File.join(struct_dir, 'references.sql'), 'a+') { |f| f << alters }
  end


  def dump_choices_data(cat, dir)
    inserts = ""
    cat.choice_sets.each do |choice_set|
      choice_set.choices.each do |choice|
        insert_template = "INSERT INTO `#{choice.choice_set.name}` (#{Choice.columns_hash.map { |c_name, _c| "`#{c_name}`"}.join(',')}) \n VALUES ("
        Choice.columns_hash.each do |column_name, column|
          value = convert_active_storage_value_to_sql_value(column.type, choice.public_send(column_name))
          insert_template << "#{value}#{',' unless column_name == Choice.columns_hash.keys.last} \n"
        end
        insert_template << ");\n\n"

        inserts << insert_template
      end
    end

    inserts
  end

  def dump_create_database(cat)
    "CREATE DATABASE #{cat.slug}; \n\n"
  end

  def dump_create_item_types_table(item_type)
    columns = common_sql_columns

    fields = item_type.fields.reject(&:multiple)
    fields.each do |field|
      columns << "`#{field.slug}` #{field.sql_type} #{field.sql_nullable} #{field.sql_default} #{field.sql_unique}#{',' unless field == fields.last} \n"
    end

    "CREATE TABLE `#{item_type.slug}` (\n#{columns}\n);"
  end

  def dump_create_reference_table(item_type)
    tables = ""
    item_type.fields.each do |field|
      # ManyToMany references have separate tables
      next unless field.multiple? && field.is_a?(Field::Reference)

      columns = "`#{item_type.slug}_id` INT NOT NULL,\n"
      columns << "`#{field.slug}_#{field.related_item_type.slug}_id` INT NOT NULL}\n"

      tables << "CREATE TABLE `#{field.slug}` (\n#{columns}\n);\n\n"
    end

    tables
  end

  def dump_create_choice_sets_table(choice_set)
    columns = ""

    Choice.columns_hash.each do |column_name, column|
      columns << "`#{column_name}` #{convert_active_storage_type_to_sql_type(column.type)} #{'NOT NULL' unless column.null}#{',' unless column_name == Choice.columns_hash.keys.last} \n"
    end

    "CREATE TABLE `#{choice_set.name}` (\n#{columns}\n);\n\n"
  end

  def dump_create_categories_table(category)
    columns = ""

    category.fields.each do |field|
      columns << "`#{field.slug}` #{field.sql_type} #{field.sql_nullable} #{field.sql_default} #{field.sql_unique}#{',' unless field == category.fields.last} \n"
    end

    # Category.columns_hash.each do |column_name, column|
    #   columns << "`#{column_name}` #{convert_active_storage_type_to_sql_type(column.type)} #{'NOT NULL' unless column.null}#{',' unless column_name == Category.columns_hash.keys.last} \n"
    # end

    "CREATE TABLE `#{category.name}` (\n#{columns}\n);\n\n"
  end

  def primary_key(item_type)
    return "" if item_type.primary_field.blank?

    "PRIMARY KEY (`#{item_type.primary_field.slug}`)"
  end

  def dump_item_data(item)
    values = ""

    values << "#{item.id}, "
    values << "#{convert_active_storage_value_to_sql_value(:datetime, item.created_at)}, "
    values << "#{convert_active_storage_value_to_sql_value(:datetime, item.updated_at)}, "

    item.fields.each do |field|
      # ManyToMany references have separate tables
      next if field.multiple?

      values << "#{sql_value(field.type, field.value_for_item(item))} #{',' unless field == item.fields.last}"
    end

    values
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
    File.write(File.join(dir, "#{it.slug}.json"), JSON.pretty_generate(dmp))
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
  #
  # def dump_data(cat, dir)
  #   data_dir = File.join(dir, 'data')
  #   # Dir.mkdir data_dir
  #   cat.item_types.each { |it| dump_items(it, data_dir) }
  # end

  def dump_items(item_type, dir)
    File.write(
      File.join(dir, "#{item_type.slug}.json"),
      JSON.pretty_generate("item-type": item_type.slug, "items": item_type.items.map(&:describe))
    )
  end

  def dump_files(cat, dir)
    files_dir = File.join(dir, 'files')
    Dir.mkdir files_dir
    FileUtils.cp_r(
      Dir.glob(File.join(Rails.public_path, 'upload', cat.slug, '*')),
      files_dir
    )
  end

  def dump_pages(cat, dir)
    pages_dir = File.join(dir, 'pages')
    Dir.mkdir pages_dir
    cat.pages.each { |p| dump_page(p, pages_dir) }
  end

  def dump_page(p, dir)
    File.write(File.join(dir, "#{p.slug}.json"), JSON.pretty_generate(p.describe))
  end

  def dump_menu_items(cat, dir)
    File.write(
      File.join(dir, "menus.json"),
      JSON.pretty_generate("menu-items": cat.menu_items.map(&:describe))
    )
  end

  private

  def file_error(msg)
    "ERROR. #{msg} Please specify an non-existing or empty directory."
  end

  def ensure_no_file_overwrite(path)
    raise(file_error("'#{path}' is a file.")) if File.exist?(path) && !File.directory?(path)
  end

  def ensure_empty_directory(dir)
    raise(file_error("'#{dir}' is not empty.")) if File.directory?(dir) && !Dir[File.join(dir, '*')].empty?
  end

  def common_sql_columns
    columns = ""

    COMMON_SQL_COLUMNS.each do |column_name, column_type|
      columns << "`#{column_name}` #{column_type} NOT NULL, "
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

  def sql_value(type, value)
    return "NULL" if value.blank?

    case type
    when "Field::Int", "Field::Decimal", "Field::Editor"
      value
    when "Field::Reference", "Field::ChoiceSet"
      # value.is_a?(Item) ? value.id : "'#{value.short_name_translations.to_json}'"
      value.id
    when "Field::Boolean"
      value == "0" ? "FALSE" : "TRUE"
    when "Field::DateTime"
      "'#{value.to_json}'"
    else
      "'#{value.to_s.gsub("'") { "\\'" }}'"
    end
  end
end
