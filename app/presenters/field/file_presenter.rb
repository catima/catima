class Field::FilePresenter < FieldPresenter
  delegate :attachment_filename, :attachment_size, :attachment_present?,
           :to => :field

  delegate :content_tag, :number_to_human_size, :to => :view

  def input(form, method, options={})
    form.form_group(method, :label => { :text => label }) do
      html = [existing_file(form) || unsaved_file]
      html << form.attachment_field(method, options.merge(:direct => true))
      html.compact.join.html_safe
    end
  end

  def value
    return nil unless attachment_present?(item)
    file_info
  end

  def file_info
    return unless (name = attachment_filename(item))
    info = ["<a href=\"#{file_url(item)}\" target=\"_blank\"><i class=\"fa fa-file\"></i> #{name}</a>"]
    info << number_to_human_size(attachment_size(item), :prefix => :si)
    info.join(", ").html_safe
  end

  def existing_file(form)
    return unless (image = value)
    [
      content_tag(:p, content_tag(:a, image, { href:file_url(item), target:"_blank" })),
      form.check_box("remove_#{uuid}", :label => "Remove this file")
    ].join.html_safe
  end

  def file_url(item)
    item.behaving_as_type.public_send("#{uuid}_url")
  end

  def unsaved_file
    return unless (info = file_info)
    content_tag(:p, info)
  end
end
