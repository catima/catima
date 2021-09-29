class ItemType < ApplicationRecord
  module Clone
    extend ActiveSupport::Concern

    def clone_fields!(original_fields)
      for original_field in original_fields
        field = self.fields.new(original_field.attributes.except("id", "uuid"))
        field.field_set_id = self.id
        field.field_set_type = 'ItemType'
        field.related_item_type_id = catalog.all_item_types.find_by(slug: original_field.related_item_type.slug).id if field.related_item_type_id?
        field.choice_set_id = catalog.choice_sets.find_by(name: original_field.choice_set.name).id if field.choice_set_id?
        if original_field.category_item_type_id
          byebug
        end

        field.save!
      end
    end

    def clone_item_views!(original_item_views)
      for original_item_view in original_item_views
        item_view = self.item_views.new(original_item_view.attributes.except("id", "item_type_id"))
        item_view.save!
      end
    end

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
