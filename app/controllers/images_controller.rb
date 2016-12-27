
class ImagesController < ApplicationController
  def thumbnail
    size = params[:size].split('x').map { |s| s.to_i }
    mode = params[:mode].to_sym.in?([:fill, :resize]) ? params[:mode].to_sym : :fill
    filename = "#{params[:image]}.#{params[:ext]}"

    src = Rails.root.join(
      'public', 'upload', params[:catalog_slug],
      params[:field_uuid], filename
    )
    raise ActiveRecord::RecordNotFound unless File.exists? src

    dest_dir = Rails.root.join(
      'public', 'thumbs', params[:catalog_slug],
      params[:size], mode.to_s, params[:field_uuid]
    )
    FileUtils.mkdir_p(dest_dir)
    dest = File.join(dest_dir, filename)

    ImageTools.thumbnail(src, dest, size, mode)
    raise ActiveRecord::RecordNotFound unless File.exists? dest

    redirect_to([
      '/thumbs', params[:catalog_slug],
      params[:size], mode.to_s, params[:field_uuid], 
      filename
    ].join('/'))
  end
end
