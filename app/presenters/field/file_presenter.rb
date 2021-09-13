class Field::FilePresenter < FieldPresenter
  delegate :tag, :number_to_human_size, :to => :view

  def input(form, method, options={})
    item_type = options[:item_type] || field.item_type.slug
    # rubocop:disable Layout/LineLength
    field_category = field.belongs_to_category? ? "data-field-category=\"#{field.category_id}\" data-field-category-choice-id=\"#{field.category_choice.id}\" data-field-category-choice-set-id=\"#{field.category_choice_set.id}\"" : ""
    # rubocop:enable Layout/LineLength

    btn_label = field.multiple ? t('presenters.field.file.add_files') : t('presenters.field.file.add_file')

    render_html(form, method, item_type, field_category, btn_label)
  end

  def value
    return nil unless value?

    file_info
  end

  def value?
    return false if raw_value.blank?

    true
  end

  def file_info
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
    info.join.html_safe
  end

  def file_url(file)
    file['path'].nil? ? nil : "/#{file['path']}"
  end

  def files_as_array
    raw_value.is_a?(Array) ? raw_value : [raw_value]
  end

  private

  # rubocop:disable Style/StringConcatenation
  def render_html(form, method, item_type, field_category, btn_label)
    [
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
      "data-file-size=\"#{field.max_file_size.megabytes}\" " \
      "data-button-text=\"" + btn_label + "\"></div>",
      "<h4>",
      "<small>#{t('presenters.field.file.size_constraint', :max_size => field.max_file_size)}</small><br>",
      "<small>#{t('presenters.field.file.types_constraint', :types => field.types)}</small>",
      "</h4>",
      "</div>"
    ].compact.join.html_safe
  end

  # rubocop:enable Style/StringConcatenation
end
