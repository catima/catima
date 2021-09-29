class ChoiceSet < ApplicationRecord
  module Clone
    extend ActiveSupport::Concern

    def clone_choices!(original_choices)
      for original_choice in original_choices
        choice = self.choices.new(original_choice.attributes.except("id", "catalog_id", "category_id", "choice_set_id"))
        choice.catalog_id = catalog_id
        choice.category_id = catalog.all_categories.find_by(name: original_choice.category.name).id if original_choice.category_id?
        choice.save!

        choice.recursively_clone_children!(original_choice.childrens)
      end
    end
  end
end
