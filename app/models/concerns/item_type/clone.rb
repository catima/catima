class ItemType < ApplicationRecord
  module Clone
    extend ActiveSupport::Concern

    def clone_fields!(original_fields)
      original_fields.each do |original_field|
        field = fields.new(original_field.attributes.except("id", "uuid"))
        field.field_set_id = id
        field.field_set_type = 'ItemType'
        field.related_item_type_id = catalog.all_item_types.find_by(slug: original_field.related_item_type.slug).id if field.related_item_type_id?
        field.choice_set_id = catalog.choice_sets.find_by(name: original_field.choice_set.name).id if field.choice_set_id?
        field.save!
      end
    end

    def clone_item_views!(original_item_views)
      original_item_views.each do |original_item_view|
        item_view = item_views.new(original_item_view.attributes.except("id", "item_type_id"))
        item_view.save!
      end
    end

    def clone_menu_items(original_menu_items)
      original_menu_items.each do |original_menu_item|
        menu_item = menu_items.new(original_menu_item.attributes.except("id", "item_type_id", "catalog_id", "page_id", "parent_id"))
        menu_item.catalog_id = catalog_id
        menu_item.save(validate: false)

        menu_item.recursively_clone_children(original_menu_item.children)
      end
    end
  end
end
