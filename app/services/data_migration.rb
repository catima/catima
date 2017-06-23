class DataMigration
  def initialize
  end

  # The structure for storing files and images in items has changed.
  # Previously, the file uploads were handled by refile and a hash with content:
  # {"size":123,"filename":"name.pdf","id":456} has been stored in the database,
  # where "id" was the filename on the viim server. "id" can be null.
  #
  # The new file upload is handled by an action in a controller, enabling
  # multifile uploads.
  # The new structure in the database for single-file fields is as follows:
  # {
  #   "name": "filename.pdf",
  #   "path": "upload/:catalog_slug/:field_uuid/:datetime_:filename.pdf",
  #   "type": "application/pdf", "size": 123
  # }
  #
  # The upload path needs to be inferred from the item type and the file
  # copied to the new location.
  def migrate_file_field_structure
    puts "migrating file field structure..."
    file_image_fields.each do |field|
      field.item_type.items.each do |item|
        file_data = field.raw_value(item)
        unless file_data.nil?
          if file_data.is_a?(Array) == false && file_data.has_key?('id')
            migrate_file_field_for_item(field, item) unless file_data['id'].nil?
          end
        end
      end
    end
  end

  private

  def file_image_fields
    flds = []
    ItemType.all.each do |item_type|
      item_type.fields.each do |field|
        flds.push(field) if field.type.in? ['Field::File', 'Field::Image']
      end
    end
    flds
  end

  def migrate_file_field_for_item(field, item)
    # build the new file data hash
    file_data = item.data[field.uuid]
    new_file_name = Time.now.to_i.to_formatted_s(:number) + '_' + format_filename(file_data['filename'])
    file_dir = File.join('upload', field.catalog.slug, field.uuid)
    new_file_data = {
      'name' => file_data['filename'],
      'path' => File.join(file_dir, new_file_name),
      'type' => mime_type(File.extname(file_data['filename']).slice(1,100)),
      'size' => file_data['size']
    }

    # copy the file to the new location
    src = Rails.root.join('public', 'system', 'refile', file_data['id'])
    dst = Rails.root.join('public', new_file_data['path'])
    FileUtils.mkdir_p(File.dirname(dst))
    FileUtils.cp(src, dst)

    # set the new file data hash and save to database
    item.data[field.uuid] = new_file_data
    item.save

    #  output information
    puts '', 'File updated:', file_data, new_file_data
  end

  def format_filename(fname)
    ext = File.extname(fname)
    basename = fname.slice(0, fname.length - ext.length)
    basename.gsub(/[^0-9_\-a-zA-Z]/, '') + ext
  end

  def mime_type(ext)
    puts 'mime_type', ext
    mime_types = {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' => 'image/jpg',
      'gif' => 'image/gif',
      'mp3' => 'audio/mpeg3',
      'doc' => 'application/msword',
      'docx' => 'application/msword',
      'txt' => 'text/plain',
      'jpeg' => 'image/jpg',
      'mp4' => 'video/mpeg'
    }
    mime_types[ext.downcase]
  end
end
