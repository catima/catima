class Field::ImagePresenter < Field::FilePresenter
  delegate :image_tag, :to => :view

  def value
    return nil if raw_value.nil?
    options[:class] = options[:style] ? options[:style] : :full
    images = files_as_array.map do |image|
      image_tag(file_url(image), options.merge(self.options))
    end
    images.join(' ').html_safe
  end

  private

  # TODO: transform image
  #   case options[:style]
  #   when :compact then [:fill, 64, 64]
  #   when :medium then [:fill, 250, 250]
  #   else [:limit, 600, 600]
  #   end
end
