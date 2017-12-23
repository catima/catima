class Field::ImagePresenter < Field::FilePresenter
  delegate :image_tag, :to => :view

  def value
    return nil if raw_value.nil?
    return image_viewer unless options[:style]
    options[:class] = options[:style] ? options[:style] : :full
    options[:class] == :full ? image_full : image_cropped
  end

  def image_full
    images = files_as_array.map do |image|
      image_tag(file_url(image, '600x600', :resize), options.merge(self.options))
    end
    images.join(' ').html_safe
  end

  def image_cropped
    # If multiple images, we select the first one for the thumbnail
    img = raw_value.class == Array ? raw_value[0] : raw_value
    return nil if img.nil?
    crop = img['crop'].nil? ? { 'x' => 0, 'y' => 0, 'width' => 100, 'height' => 100 } : img['crop']
    crop = [crop['x'], crop['y'], crop['width'], crop['height']].map(&:round)
    transform = case options[:class]
    when :compact then [:fill, '100x100']
    else [:fill, '250x250']
    end
    images = files_as_array
    image_tag(file_url(images[0], transform[1], transform[0], crop), options.merge(self.options)).html_safe
  end

  def file_url(file, size=nil, mode=:fill, crop=[0, 0, 100, 100])
    return nil if file['path'].nil?
    return "/#{file['path']}" if size.nil?
    path_parts = file['path'].split('/')
    crop_str = mode == :fill ? '/' + crop.map(&:to_s).join(',') : ''
    "/thumbs/#{path_parts[1]}/#{size}/#{mode}#{crop_str}/#{path_parts[2]}/#{path_parts[3]}"
  end

  def image_viewer
    thumbs = files_as_array.map do |image|
      file_url(image, '300x200', :resize)
    end
    images = files_as_array.map { |img| "/#{img['path']}" }
    @view.render('fields/images', thumbnails: thumbs, images: images)
  end
end
