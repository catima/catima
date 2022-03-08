# Module mixed into Container that encapsulates all the sort logic.
module Container::Sort
  CHOICES = {
    "f-asc" => "Field/Ascendant",
    "f-desc" => "Field/Descendant",
    "ca-asc" => "CreatedAt/Ascendant",
    "ca-desc" => "CreatedAt/Descendant"
  }.freeze

  ASCENDING = "ASC".freeze
  DESCENDING = "DESC".freeze
  FIELD = "FIELD".freeze
  CREATED_AT = "CREATED_AT".freeze

  # Return the sort choices for the line style
  def self.line_choices
    CHOICES.reject { |key, _name| key.start_with?("ca-") }
  end

  # Return the direction of a sort, default to ASC
  def self.direction(sort)
    return ASCENDING unless CHOICES.key?(sort)

    CHOICES[sort].end_with?("/Ascendant") ? ASCENDING : DESCENDING
  end

  # Return the type of a sort, default to FIELD
  def self.type(sort)
    return FIELD unless CHOICES.key?(sort)

    CHOICES[sort].start_with?("Field/") ? FIELD : CREATED_AT
  end
end
