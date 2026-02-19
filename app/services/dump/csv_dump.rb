class Dump::CSVDump < Dump
  require "csv"

  def dump(catalog, directory, locale, with_files: true, with_catima_id: false, use_slugs: false)
    I18n.with_locale(locale) do
      cat = Catalog.find_by(slug: catalog)
      raise "ERROR. Catalog '#{catalog}' not found." if cat.nil?

      # Check if directory exists; create if necessary,
      # if not empty raise an error.
      create_output_dir directory unless File.directory?(directory)

      # Write meta.json file. Contains information about
      # the dump, format version etc.
      write_meta directory

      create_files(cat, directory)

      # First loop to check if there are categories among choices
      categories_fields = build_csv_header(cat)

      dump_headers(cat, categories_fields, directory, with_catima_id: with_catima_id, use_slugs: use_slugs)

      dump_data(cat, categories_fields, directory, with_catima_id: with_catima_id)

      dump_files(cat, directory) if with_files
    end
  end

  private

  def msg(txt)
    Rails.logger.info txt unless Rails.env.test?
  end

  def create_files(catalog, directory)
    catalog.item_types.find_each do |item_type|
      File.write(File.join(directory, "#{item_type.slug}.csv"), '')
    end
  end

  def build_csv_header(catalog)
    categories_fields = {}
    catalog.items.find_in_batches(:batch_size => 100) do |items|
      items.each do |item|
        categories_fields[item.item_type.id] = []

        item.fields.each do |field|
          next unless field.is_a?(Field::ChoiceSet)

          value = field.value_for_item(item)
          next if value.blank?

          if field.multiple?
            value.each do |choice|
              next if choice.category.blank?

              choice.category.fields.map { |f| categories_fields = add_category_field(categories_fields, item, f) }
            end
          elsif value.category.present?
            value.category.fields.find_each { |f| categories_fields = add_category_field(categories_fields, item, f) }
          end
        end
      end
    end

    categories_fields
  end

  def add_category_field(categories_fields, item, field)
    return categories_fields unless categories_fields.key?(item.item_type.id)

    categories_fields[item.item_type.id] << field unless categories_fields[item.item_type.id].include?(field)

    categories_fields
  end

  def dump_headers(catalog, categories_fields, directory, with_catima_id: false, use_slugs: false)
    catalog.item_types.each do |item_type|
      msg("Dumping headers for items of ItemType #{item_type.slug}")

      columns = use_slugs ? item_type.fields.map(&:slug) : item_type.fields.map(&:name)
      columns.prepend("Catima ID") if with_catima_id

      if categories_fields[item_type.id].present?
        categories_fields[item_type.id].each do |field|
          columns << "#{Category.find(field.category_id).name}_#{field.slug}"
        end
      end

      CSV.open(File.join(directory, "#{item_type.slug}.csv"), "a+") { |csv| csv << columns }
    end
  end

  def dump_data(catalog, categories_fields, directory, with_catima_id: false)
    ActiveRecord::Base.uncached do
      catalog.item_types.includes(:fields, :items).select(:id, :slug).reorder('').each do |item_type|
        msg("Dumping data for items of ItemType #{item_type.slug}")

        fields = item_type.fields

        item_type.items.find_in_batches(:batch_size => 100) do |items|
          CSV.open(File.join(directory, "#{item_type.slug}.csv"), "a") do |csv|
            items.each do |item|
              values = fields.map { |f| f.csv_value(item) }
              values.prepend(item.id) if with_catima_id
              csv << values.concat(categories_fields[item_type.id].map { |f| f.csv_value(item) })
            end
          end
        end
      end
    end
  end
end
