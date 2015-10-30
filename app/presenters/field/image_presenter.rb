class Field::ImagePresenter < Field::FilePresenter
  delegate :image_tag, :attachment_url, :to => :view

  def value(style)
    return if raw_value.nil?
    src_1x, src_2x = image_sources(style)

    srcset = "#{src_1x} 1x,#{src_2x} 2x"
    options = { :srcset => srcset, :alt => attachment_filename(item) }
    image_tag(src_1x, options)
  end

  private

  def image_sources(style)
    transform = transformation_args(style)
    src_1x = attachment_url(item.behaving_as_type, uuid, *transform)
    src_2x = attachment_url(
      item.behaving_as_type,
      uuid,
      transform.first,
      *transform[1..-1].map { |i| i * 2 }
    )
    [src_1x, src_2x]
  end

  def transformation_args(style)
    case style
    when :compact
      [:fill, 64, 64]
    else
      [:limit, 600, 600]
    end
  end
end
