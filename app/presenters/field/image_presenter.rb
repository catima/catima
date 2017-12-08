class Field::ImagePresenter < Field::FilePresenter
  delegate :image_tag, :to => :view

  def value
    return nil if raw_value.nil?
    return image_viewer unless options[:style]
    options[:class] = options[:style] ? options[:style] : :full
    crop = raw_value['crop'].nil? ? { 'x' => 0, 'y' => 0, 'width' => 100, 'height' => 100 } : raw_value['crop']
    crop = [crop['x'], crop['y'], crop['width'], crop['height']].map(&:round)
    transform = case options[:class]
    when :compact then [:fill, '100x100']
    when :medium then [:fill, '250x250']
    else [:resize, '600x600']
    end
    images = files_as_array.map do |image|
      image_tag(file_url(image, transform[1], transform[0], crop), options.merge(self.options))
    end
    images.join(' ').html_safe
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
    images = files_as_array.map { |img| '/' + img['path'] }
    @view.render('fields/images', thumbnails: thumbs, images: images)
  end
end
