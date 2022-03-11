# Module mixed into Container that encapsulates all the sort logic.
module Container::Sort
  CHOICES = {
    "asc" => "Primary ascendant",
    "desc" => "Primary descendant",
    "ca" => "Created at"
  }.freeze

  def line_choices
    CHOICES.reject { |key, _name| key == "ca" }
  end
end
