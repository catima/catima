module SummernoteHelper
  def summernote_text_area(form, method)
    value = form.object.public_send(method).to_s
    form.text_area(
      method,
      :rows => 16,
      :value => value,
      :data => { :provider => "summernote" }
    )
  end
end
