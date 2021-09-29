class Catalog < ApplicationRecord
  module Clone
    extend ActiveSupport::Concern

    def clone!
      Catalog.transaction do
        cloned = self.dup

        cloned.created_at = nil
        cloned.name = "Copy of #{self.name}"
        cloned.slug = "copy-#{self.slug}"
        cloned.save!

        # cloned.pages = nil
        # cloned.menu_items = nil (with page_id)
        cloned.clone_pages(self.pages)

        # cloned.menu_items = nil (without page_id && item_type_id)
        cloned.clone_menu_items(self.menu_items.where(item_type_id: nil, page_id: nil, parent_id: nil))

        # cloned.categories = nil
        cloned.clone_categories!(self.all_categories)
        # cloned.choice_sets = nil
        cloned.clone_choice_sets!(self.choice_sets)

        # cloned.item_types = nil
        # cloned.menu_items = nil (with item_type_id)
        cloned.clone_item_types!(self.all_item_types)

        cloned.clone_categories_relations!(self.all_categories)

        cloned.clone_item_types_relations(self.all_item_types)

        # cloned.advanced_search_configurations = nil
        cloned.clone_advanced_search_configurations!(self.advanced_search_configurations)
        cloned
      end
    end

    protected

    # TODO fix menu_item_ids
    def clone_pages(original_pages)
      for original_page in original_pages
        page = self.pages.new(original_page.attributes.except("id", "reviewer_id"))
        page.save(validate: false)
        page.clone_menu_items(original_page.menu_items.where(parent_id: nil))
      end
    end

    def clone_menu_items(original_menu_items)
      for original_menu_item in original_menu_items
        menu_item = self.menu_items.new(original_menu_item.attributes.except("id"))
        menu_item.save(validate: false)
        menu_item.recursively_clone_children(original_menu_item.children)
      end
    end

    def clone_categories!(original_categories)
      for original_category in original_categories
        category = self.categories.new(original_category.attributes.except("id", "uuid"))
        category.save!
      end
    end

    def clone_categories_relations!(original_categories)
      for original_category in original_categories
        category = all_categories.find_by(name: original_category.name)
        category.clone_fields!(original_category.fields)
      end
    end

    def clone_choice_sets!(original_choice_sets)
      for original_choice_set in original_choice_sets
        choice_set = self.choice_sets.new(original_choice_set.attributes.except("id", "uuid"))
        choice_set.save!

        choice_set.clone_choices!(original_choice_set.choices.where(parent_id: nil))
      end
    end

    def clone_item_types!(original_item_types)
      for original_item_type in original_item_types
        item_type = self.item_types.new(original_item_type.attributes.except("id", "item_ids", "field_ids" "item_view_ids", "menu_item_ids", "advanced_search_configuration_ids"))
        item_type.save!
      end
    end

    def clone_item_types_relations(original_item_types)
      for original_item_type in original_item_types
        item_type = all_item_types.find_by(slug: original_item_type.slug)
        item_type.clone_fields!(original_item_type.fields)
        item_type.clone_item_views!(original_item_type.item_views)
        item_type.clone_menu_items(original_item_type.menu_items.where(parent_id: nil))
      end
    end

    def clone_advanced_search_configurations!(original_advanced_search_configurations)
      for original_advanced_search_configuration in original_advanced_search_configurations
        advanced_search_configuration = self.advanced_search_configurations.new(original_advanced_search_configuration.attributes.except('id', 'item_type_id'))
        advanced_search_configuration.item_type_id = all_item_types.find_by(slug: original_advanced_search_configuration.item_type.slug).id
        advanced_search_configuration.fields = advanced_search_configuration.fields.map do |k, v|
          [advanced_search_configuration.item_type.fields.find_by(slug: Field.find_by(uuid: k).slug).uuid, v]
        end.to_h
        advanced_search_configuration.save!
      end
    end
  end
end
