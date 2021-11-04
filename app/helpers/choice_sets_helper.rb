# == Schema Information
#
# Table name: choice_sets
#
#  catalog_id     :integer
#  created_at     :datetime         not null
#  deleted_at :datetime
#  id             :integer          not null, primary key
#  name           :string
#  slug           :string
#  updated_at     :datetime         not null
#  uuid           :string
#

module ChoiceSetsHelper
  def filter_category_fields(choices)
    choices.map do |choice|
      {
        :value => choice[:value],
        :key => choice[:key],
        label: choice[:label],
        has_childrens: choice[:has_childrens],
        :category_data => displayable_category_fields(choice[:category_data])
      }
    end
  end

  # Returns all displayable fields for a category (filterable). Mainly used for the choiceset
  # component in advanced search.
  #
  # Also removes the restricted fields if the current user is not a catalog staff.
  def displayable_category_fields(fields)
    fields.select { |f| f.filterable? && f.displayable_to_user?(current_user) }
  end
end
