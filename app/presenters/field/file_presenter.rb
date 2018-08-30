class Field::FilePresenter < FieldPresenter
  delegate :content_tag, :number_to_human_size, :to => :view

  def input(form, method, options={})
    item_type = options[:item_type] || field.item_type.slug
    field_category = field.belongs_to_category? ? "data-field-category=\"#{field.category_id}\"" : ''
    html = [
      form.text_area(
        "#{method}_json",
        input_defaults(options).reverse_merge(:rows => 1, 'data-field-type' => 'file')
      ),
      '<div class="form-component">',
      "<div class=\"form-group file-upload\" #{field_category} " \
          "id=\"fileupload_#{method}\" " \
          "data-field=\"#{method}\" " \
          "data-field-type=\"#{field.type}\" " \
          "data-multiple=\"#{field.multiple}\" " \
          "data-required=\"#{field.required?}\" " \
          "data-fieldname=\"#{field.name}\" " \
          "data-upload-url=\"/#{field.catalog.slug}/#{I18n.locale}/admin/#{item_type}/upload\" " \
          "data-file-types=\"#{field.types}\" " \
          "data-button-text=\"" + (field.multiple == true ? 'Add files' : "Add file") + "\"></div>",
      '</div>'
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
        "<a style=\"margin-left: 7px;\" href=\"#{file_url(file)}\" download=\"#{file['name']}\">" \
          "<i class=\"fa fa-download\"></i>" \
        "</a>" \
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
