class Field::FilePresenter < FieldPresenter
  delegate :content_tag, :number_to_human_size, :to => :view

  def input(form, method, options={})
    html = [
      form.text_area(
        "#{method}_json",
        input_defaults(options).reverse_merge(:rows => 1, 'data-field-type' => 'file')
      ),
      "<div class=\"form-group form-group-dropzone\">",
      "<div " \
        "id=\"dropzone_#{method}\" " \
        "class=\"dropzone #{field.multiple ? 'dropzone-multiple' : ''}\" " \
        "data-field=\"#{method}\" " \
        "data-multiple=\"#{field.multiple}\" " \
        "data-required=\"#{field.required?}\" " \
        "data-fieldname=\"#{field.name}\" " \
        "data-file-types=\"#{field.types}\"></div>",
      "<div id=\"dz_msg_#{method}\"></div>",
      "</div>"
    ]
    html.compact.join.html_safe
  end

  def value
    file_info
  end

  def file_info
    return nil if raw_value.nil?
    info = files_as_array.map do |file|
      "<div class=\"file-link\">" \
        "<a href=\"#{file_url(file)}\" target=\"_blank\">" \
          "<i class=\"fa fa-file\"></i> #{file['name']}" \
        "</a>" \
        ", #{number_to_human_size(file['size'], :prefix => :si)}" \
      "</div>"
    end
    info.join().html_safe
  end

  def file_url(file)
    file['path'].nil? ? nil : "/#{file['path']}"
  end

  def files_as_array
    raw_value.is_a?(Array) ? raw_value : [ raw_value ]
  end

end
