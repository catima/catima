require 'csv'

class Dump::CsvDump < ::Dump
  def initialize
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

    cat.item_types.each do |item_type|
      File.write(File.join(directory, "#{item_type.slug}.csv"), '')
    end

    cat.items.each do |item|
      CSV.open(File.join(directory, "#{item.item_type.slug}.csv"), "a+") do |csv|
        columns = item.fields.map(&:slug)
        csv << columns unless csv.include?(columns)
        csv << item.fields.map { |f| f.field_value_for_all_item(item) }
      end
    end

    # dump_files(cat, directory)
  end
end
