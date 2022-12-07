class Choice < ApplicationRecord
  module Clone
    extend ActiveSupport::Concern

    def recursively_clone_children!(original_children)
      original_children.each do |original_child|
        child = childrens.new(original_child.attributes.except("id", "catalog_id", "category_id", "choice_set_id"))
        child.catalog_id = catalog_id
        child.choice_set_id = catalog.choice_sets.find_by(name: original_child.choice_set.name).id
        child.category_id = catalog.all_categories.find_by(name: original_child.category.name).id if original_child.category_id?
        child.parent_id = id
        child.save!

        child.recursively_clone_children!(original_child.childrens)
      end
    end
  end
end
