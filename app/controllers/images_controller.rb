
class ImagesController < ApplicationController
  def thumbnail
    size = params[:size].split('x').map { |s| s.to_i }
    filename = "#{params[:image]}.#{params[:ext]}"

    src = Rails.public_path.join(
      'upload', params[:catalog_slug].to_s,
      params[:field_uuid].to_s, filename
    )
    raise ActiveRecord::RecordNotFound unless File.exist? src

    dest_dir = Rails.public_path.join(
      'thumbs', params[:catalog_slug].to_s,
      params[:size].to_s, 'resize', params[:field_uuid].to_s
    )
    FileUtils.mkdir_p(dest_dir)
    dest = File.join(dest_dir.to_s, filename)

    ImageTools.thumbnail(src, dest, size, :resize)
    raise ActiveRecord::RecordNotFound unless File.exist? dest

    redirect_to([
      '/thumbs', params[:catalog_slug],
      params[:size], 'resize', params[:field_uuid],
      filename
    ].join('/'))
  end

  def thumbnail_default_cropped
    filename = "#{params[:image]}.#{params[:ext]}"
    redirect_to([
      '/thumbs', params[:catalog_slug],
      params[:size], 'fill', '0,0,100,100', params[:field_uuid],
      filename
    ].join('/'))
  end

  def thumbnail_cropped
    size = params[:size].split('x').map { |s| s.to_i }
    filename = "#{params[:image]}.#{params[:ext]}"
    crop = params[:crop].split(',').map { |s| s.to_i }
    crop_str = crop.map { |i| i.to_s }.join(',')

    src = Rails.public_path.join(
      'upload', params[:catalog_slug].to_s,
      params[:field_uuid].to_s, filename
    )
    raise ActiveRecord::RecordNotFound unless File.exist? src

    dest_dir = Rails.public_path.join(
      'thumbs', params[:catalog_slug].to_s,
      params[:size].to_s, 'fill', crop_str, params[:field_uuid].to_s
    )
    FileUtils.mkdir_p(dest_dir)
    dest = File.join(dest_dir.to_s, filename)

    ImageTools.thumbnail(src, dest, size, :fill, crop)
    raise ActiveRecord::RecordNotFound unless File.exist? dest

    redirect_to([
      '/thumbs', params[:catalog_slug],
      params[:size], 'fill', crop_str, params[:field_uuid],
      filename
    ].join('/'))
  end
end
