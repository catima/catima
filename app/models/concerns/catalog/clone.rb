class Catalog < ApplicationRecord
  module Clone
    extend ActiveSupport::Concern

    def clone!(new_slug)
      Catalog.transaction do
        cloned = dup

        cloned.name = "Copy of #{name}"
        cloned.slug = new_slug
        cloned.save!

        cloned.clone_pages(pages)
        cloned.clone_menu_items(menu_items.where(item_type_id: nil, page_id: nil, parent_id: nil))
        cloned.clone_categories!(all_categories)
        cloned.clone_choice_sets!(choice_sets)
        cloned.clone_item_types!(all_item_types)
        cloned.clone_categories_relations!(all_categories)
        cloned.clone_item_types_relations(all_item_types)
        cloned.clone_advanced_search_configurations!(advanced_search_configurations)
        cloned
      end
    end

    protected

    def clone_pages(original_pages)
      original_pages.each do |original_page|
        page = pages.new(original_page.attributes.except("id", "reviewer_id"))
        page.save(validate: false)
        page.clone_menu_items(original_page.menu_items.where(parent_id: nil))
      end
    end

    def clone_menu_items(original_menu_items)
      original_menu_items.each do |original_menu_item|
        menu_item = menu_items.new(original_menu_item.attributes.except("id"))
        menu_item.save(validate: false)
        menu_item.recursively_clone_children(original_menu_item.children)
      end
    end

    def clone_categories!(original_categories)
      original_categories.each do |original_category|
        category = categories.new(original_category.attributes.except("id", "uuid"))
        category.save!
      end
    end

    def clone_categories_relations!(original_categories)
      original_categories.each do |original_category|
        category = all_categories.find_by(name: original_category.name)
        category.clone_fields!(original_category.fields)
      end
    end

    def clone_choice_sets!(original_choice_sets)
      original_choice_sets.each do |original_choice_set|
        choice_set = choice_sets.new(original_choice_set.attributes.except("id", "uuid"))
        choice_set.save!

        choice_set.clone_choices!(original_choice_set.choices.where(parent_id: nil))
      end
    end

    def clone_item_types!(original_item_types)
      original_item_types.each do |original_item_type|
        item_type = item_types.new(original_item_type.attributes.except("id", "item_ids", "field_ids", "item_view_ids", "menu_item_ids", "advanced_search_configuration_ids"))
        item_type.save!
      end
    end

    def clone_item_types_relations(original_item_types)
      original_item_types.each do |original_item_type|
        item_type = all_item_types.find_by(slug: original_item_type.slug)
        item_type.clone_fields!(original_item_type.fields)
        item_type.clone_item_views!(original_item_type.item_views)
        item_type.clone_menu_items(original_item_type.menu_items.where(parent_id: nil))
      end
    end

    def clone_advanced_search_configurations!(original_advanced_search_configurations)
      original_advanced_search_configurations.each do |original_advanced_search_configuration|
        advanced_search_configuration = advanced_search_configurations.new(original_advanced_search_configuration.attributes.except('id', 'item_type_id'))
        advanced_search_configuration.item_type_id = all_item_types.find_by(slug: original_advanced_search_configuration.item_type.slug).id
        advanced_search_configuration.fields = advanced_search_configuration.fields.transform_keys do |k|
          advanced_search_configuration.item_type.fields.find_by(slug: Field.find_by(uuid: k).slug).uuid
        end
        advanced_search_configuration.save!
      end
    end
  end
end
