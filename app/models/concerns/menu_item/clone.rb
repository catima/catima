class MenuItem < ApplicationRecord
  module Clone
    extend ActiveSupport::Concern

    def recursively_clone_children(original_children)
      original_children.each do |original_child|
        child = self.children.new(original_child.attributes.except("id", "item_type_id", "catalog_id", "page_id", "parent_id"))
        child.catalog_id = catalog_id
        child.parent_id = id
        child.save(validate: false)

        child.recursively_clone_children(original_child.children)
      end
    end
  end
end
