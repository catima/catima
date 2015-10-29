class Field::ImagePresenter < Field::FilePresenter
  delegate :image_tag, :attachment_url, :to => :view

  def value
    image_tag(attachment_url(item.behaving_as_type, uuid, :fill, 64, 64))
  end
end
