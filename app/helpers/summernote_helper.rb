module SummernoteHelper
  def summernote_text_area(form, method)
    value = form.object.public_send(method).to_s
    form.text_area(
      method,
      :rows => 16,
      :value => summernote_safe_value(value),
      :data => { :provider => "summernote" }
    )
  end

  # Safari has a hard time rendering base64 images if the base64 data does not
  # contain line breaks (it will peg the CPU for seconds or minutes). The
  # workaround is to split the base64 into short lines. This method detects
  # base64 image data inside an HTML value and modifies it by inserting line
  # breaks. Returns a modified copy of the original value.
  def summernote_safe_value(value)
    value.gsub(%r{"data:image/jpeg;base64,([^"]*)"}) do
      base64_data = $1.scan(/.{1,76}/).join("\n")
      %("data:image/jpeg;base64,#{base64_data}")
    end
  end
end
