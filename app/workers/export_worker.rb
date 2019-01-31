require 'zip'

class ExportWorker
  include Sidekiq::Worker

  def perform(export_id, category)
    dir = Rails.env.development? ? Rails.root.join('tmp', 'exports') : Dir.mktmpdir(SecureRandom.hex)

    export = find_export(export_id)

    case category
    when "catima"
      catima_export(export, dir)
    when "sql"
      sql_export(export, dir)
    when "csv"
      csv_export(export, dir)
    else
      export.update(status: "error")
    end

    # FileUtils.remove_entry dir
  end

  private

  def catima_export(export, dir)
    status = "ready"
    # begin
      # Dump::CatalogDump.new.dump(export.catalog.slug, dir)
      Dump::CatalogDump.new.dump(export.catalog.slug, Rails.root.join('tmp', 'exports', 'catima'))
      zip(dir, export.pathname)
    rescue StandardError
      status = "error"
    end
    export.update(status: status)
    send_mail(export)
  end

  def sql_export(export, dir)
    status = "ready"
    # begin
      Dump::SqlDump.new.dump(export.catalog.slug, Rails.root.join('tmp', 'exports', 'sql'))
      # zip(dir, export.pathname)
    # rescue StandardError
    #   status = "error"
    # end
    export.update(status: status)
    # send_mail(export)
  end

  def csv_export(export, dir)
    status = "ready"
    # begin
      Dump::CsvDump.new.dump(export.catalog.slug, Rails.root.join('tmp', 'exports', 'csv'))
      # zip(dir, export.pathname)
    # rescue StandardError
    #   status = "error"
    # end
    export.update(status: status)
    send_mail(export)
  end

  def find_export(id)
    Export.find_by(id: id)
  end

  def send_mail(export)
    return unless export.status.eql? "ready"

    ExportMailer.send_message(export).deliver_now
  end

  # Zip the input directory recursively
  def zip(input_dir, output_file)
    entries = Dir.entries(input_dir) - %w(. ..)

    Zip::File.open(output_file, Zip::File::CREATE) do |zipfile|
      write_entries input_dir, entries, '', zipfile
    end
  end

  # A helper method to make the recursion work
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
