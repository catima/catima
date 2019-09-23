require 'fileutils'

class Dump
  def create_output_dir(dir)
    ensure_no_file_overwrite(dir)
    ensure_empty_directory(dir)
    FileUtils.mkdir_p(dir) unless File.exist?(dir)
  end

  def write_meta(dir)
    meta = { dump_created_at: Time.now.utc.to_s, dump_version: '1.0' }
    File.write(File.join(dir, 'meta.json'), JSON.pretty_generate(meta))
  end

  def dump_files(cat, dir)
    files_dir = File.join(dir, 'files')
    Dir.mkdir files_dir
    FileUtils.cp_r(
      Dir.glob(File.join(Rails.public_path, 'upload', cat.slug, '*')),
      files_dir
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
end
