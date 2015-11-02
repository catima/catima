class Field::FilePresenter < FieldPresenter
  delegate :attachment_filename, :attachment_size, :attachment_present?,
           :to => :field

  delegate :content_tag, :number_to_human_size, :to => :view

  def input(form, method, options={})
    form.form_group(method, :label => { :text => label }) do
      html = [existing_file(form)]
      html << form.attachment_field(method, options.merge(:direct => true))
      html.compact.join.html_safe
    end
  end

  def value
    return nil unless attachment_present?(item)
    info = [attachment_filename(item)]
    info << number_to_human_size(attachment_size(item), :prefix => :si)
    info.join(", ")
  end

  def existing_file(form)
    return unless (image = value)
    [
      content_tag(:p, image),
      form.check_box("remove_#{uuid}", :label => "Remove this file")
    ].join.html_safe
  end
end
