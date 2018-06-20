require 'rubygems'
require 'zip'

class ExportWorker
  include Sidekiq::Worker

  def perform(export_id, catalog_slug, category, user_id)
    dir = Dir.mktmpdir(SecureRandom.hex)

    catalog = find_catalog(catalog_slug)
    export = find_export(export_id)
    user = find_user(user_id)

    case category
    when "Export::Catima"
      catima_export(export, catalog, user, dir)
    else
      return
    end

    FileUtils.remove_entry dir
  end

  private

  def catima_export(export, catalog, user, dir)
    CatalogDump.new.dump(catalog.slug, dir)

    zip(dir, export.pathname)

    ExportMailer.send_message(export, user, catalog).deliver_now

    export.update(status: "ready")
  end

  def find_user(id)
    User.find_by(id: id)
  end

  def find_catalog(slug)
    Catalog.find_by(slug: slug)
  end

  def find_export(id)
    Export.find_by(id: id)
  end

  # Zip the input directory.
  def zip(input_dir, output_file)
    entries = Dir.entries(input_dir) - %w(. ..)

    Zip::File.open(output_file, Zip::File::CREATE) do |zipfile|
      write_entries input_dir, entries, '', zipfile
    end
  end

  # A helper method to make the recursion work.
  def write_entries(input_dir, entries, path, zipfile)
    entries.each do |e|
      zipfile_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(input_dir, zipfile_path)

      if File.directory? disk_file_path
        recursively_deflate_directory(input_dir, disk_file_path, zipfile, zipfile_path)
      else
        put_into_archive(disk_file_path, zipfile, zipfile_path)
      end
    end
  end

  def recursively_deflate_directory(input_dir, disk_file_path, zipfile, zipfile_path)
    zipfile.mkdir zipfile_path
    subdir = Dir.entries(disk_file_path) - %w(. ..)
    write_entries input_dir, subdir, zipfile_path, zipfile
  end

  def put_into_archive(disk_file_path, zipfile, zipfile_path)
    zipfile.get_output_stream(zipfile_path) do |f|
      f.write(File.open(disk_file_path, 'rb').read)
    end
  end
end
