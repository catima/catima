module ItemMapsHelper
  def popup_content
    render(:partial => "advanced_searches/popup_content")
  end
  # def popup_content(fields, item)
  #   content = ""
  #   fields.each do |field|
  #     value_for_item = field.field_value_for_item(item)
  #
  #     content << "<p>#{}#{value_for_item unless value_for_item.nil?}</p>"
  #   end
  #
  #   content
  # end
end
