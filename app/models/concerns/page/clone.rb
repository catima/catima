class Page < ApplicationRecord
  module Clone
    extend ActiveSupport::Concern

    def clone_menu_items(original_menu_items)
      for original_menu_item in original_menu_items
        menu_item = self.menu_items.new(original_menu_item.attributes.except("id", "item_type_id", "catalog_id", "page_id", "parent_id"))
        menu_item.catalog_id = catalog_id
        menu_item.save(validate: false)

        menu_item.recursively_clone_children(original_menu_item.children)
      end
    end
  end
end
