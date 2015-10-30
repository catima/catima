class Field::FilePresenter < FieldPresenter
  delegate :attachment_filename, :attachment_size, :to => :field
  delegate :number_to_human_size, :to => :view

  def input(form, method, options={})
    form.form_group(method, :label => { :text => label }) do
      form.attachment_field(method, options)
    end
  end

  def value(_style)
    return nil if super.blank?
    info = [attachment_filename(item)]
    info << number_to_human_size(attachment_size(item), :prefix => :si)
    info.join(", ")
  end
end
