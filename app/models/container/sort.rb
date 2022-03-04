# Module mixed into Container that encapsulates all the sort logic.
module Container::Sort
  CHOICES = {
    "ca" => "Created at",
    "asc" => "Primary ascendant",
    "desc" => "Primary descendant"
  }.freeze

  def line_choices
    CHOICES.reject { |key, _name| key == "ca" }
  end
end
