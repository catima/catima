# Module mixed into Field that encapsulates all the style logic (single,
# multiple, required, optional, etc.).
module Field::Style
  CHOICES = {
    "single" => "Single value – optional",
    "single-required" => "Single value – required",
    "multiple" => "Multiple values – optional",
    "multiple-required" => "Multiple values – at least one",
    "multiple-ordered" => "Multiple ordered values – optional",
    "multiple-ordered-required" => "Multiple ordered values – at least one"
  }.freeze

  def style_choices
    CHOICES
  end

  # TODO: test
  def style=(key)
    return if key.blank?
    self.required = !!(key =~ /required/)
    self.multiple = !!(key =~ /multiple/)
    self.ordered = !!(key =~ /ordered/)
  end

  def style
    key = []
    key << (multiple? ? "multiple" : "single")
    key << "ordered" if multiple? && ordered?
    key << "required" if required?
    key.join("-")
  end
end
