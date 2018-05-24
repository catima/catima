module ApplicationHelper
  def slug_help_text
    "Lower case letters, numbers, and hyphens only. No accented characters."
  end

  def base_class_name(model)
    model.class.name.split('::').first.downcase
  end
end
