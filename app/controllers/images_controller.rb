
class ImagesController < ApplicationController
  def thumbnail
    size = params[:size].split('x').map { |s| s.to_i }
    filename = "#{params[:image]}.#{params[:ext]}"

    src = Rails.root.join(
      'public', 'upload', params[:catalog_slug],
      params[:field_uuid], filename
    )
    raise ActiveRecord::RecordNotFound unless File.exists? src

    dest_dir = Rails.root.join(
      'public', 'thumbs', params[:catalog_slug],
      params[:size], 'resize', params[:field_uuid]
    )
    FileUtils.mkdir_p(dest_dir)
    dest = File.join(dest_dir, filename)

    ImageTools.thumbnail(src, dest, size, :resize)
    raise ActiveRecord::RecordNotFound unless File.exists? dest

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

    src = Rails.root.join(
      'public', 'upload', params[:catalog_slug],
      params[:field_uuid], filename
    )
    raise ActiveRecord::RecordNotFound unless File.exists? src

    dest_dir = Rails.root.join(
      'public', 'thumbs', params[:catalog_slug],
      params[:size], 'fill', crop_str, params[:field_uuid]
    )
    FileUtils.mkdir_p(dest_dir)
    dest = File.join(dest_dir, filename)

    ImageTools.thumbnail(src, dest, size, :fill, crop)
    raise ActiveRecord::RecordNotFound unless File.exists? dest

    redirect_to([
      '/thumbs', params[:catalog_slug],
      params[:size], 'fill', crop_str, params[:field_uuid],
      filename
    ].join('/'))
  end
end
