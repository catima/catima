# Module mixed into Container that encapsulates all the sort logic.
module Container::Sort
  CHOICES = {
    "f-asc" => "Field/Ascendant",
    "f-desc" => "Field/Descendant",
    "ca-asc" => "CreatedAt/Ascendant",
    "ca-desc" => "CreatedAt/Descendant",
    "ua-asc" => "UpdatedAt/Ascendant",
    "ua-desc" => "UpdatedAt/Descendant"
  }.freeze

  FIELD = "FIELD".freeze
  CREATED_AT = "CREATED_AT".freeze
  UPDATED_AT = "UPDATED_AT".freeze

  # Return the sort choices for the line style
  def self.line_choices
    CHOICES.reject { |key, _name| key.start_with?("ca-") || key.start_with?("ua-") }
  end

  # Return the direction of a sort, nil if not a container sort choice
  def self.direction(sort)
    return nil unless CHOICES.key?(sort)

    CHOICES[sort].end_with?("/Ascendant") ? ItemList::Sort.ascending : ItemList::Sort.descending
  end

  # Return the type of a sort (FIELD|CREATED_AT|UPDATED_AT),
  # nil if not a container sort choice
  def self.type(sort)
    return nil unless CHOICES.key?(sort)

    if CHOICES[sort].start_with?("Field/")
      FIELD
    elsif CHOICES[sort].start_with?("CreatedAt/")
      CREATED_AT
    elsif CHOICES[sort].start_with?("UpdatedAt/")
      UPDATED_AT
    else
      FIELD
    end
  end
end
