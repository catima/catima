# == Schema Information
#
# Table name: choice_sets
#
#  catalog_id     :integer
#  created_at     :datetime         not null
#  deactivated_at :datetime
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
        :category_data => displayable_category_fields(choice[:category_data])
      }
    end
  end

  # Returns all displayable fields for a category. Mainly used for the choiceset
  # component in advanced search.
  #
  # Removes the following fields:
  # - Restricted fields if the current user is not a catalog staff
  # - Reference fields
  # - Choiceset fields
  def displayable_category_fields(fields)
    fields.select { |f| f.filterable? && f.displayable_to_user?(current_user) }
  end
end
