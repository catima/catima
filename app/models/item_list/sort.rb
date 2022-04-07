# Module mixed into ItemList that encapsulates all the sort logic.
module ItemList::Sort
  DIRECTIONS = %w(ASC DESC).freeze

  def self.ascending
    DIRECTIONS.at(0)
  end

  def self.descending
    DIRECTIONS.at(1)
  end

  def self.included?(sort)
    return false unless sort

    return true if ItemList::Sort::DIRECTIONS.include?(sort)

    false
  end
end
