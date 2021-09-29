class Category < ApplicationRecord
  module Clone
    extend ActiveSupport::Concern

    def clone_fields!(original_fields)
      original_fields.each do |original_field|
        field = self.fields.new(original_field.attributes.except("id", "uuid"))
        field.field_set_id = self.id
        field.field_set_type = 'Category'
        field.related_item_type_id = catalog.all_item_types.find_by(slug: original_field.related_item_type.slug).id if field.related_item_type_id?
        field.choice_set_id = catalog.choice_sets.find_by(name: original_field.choice_set.name).id if field.choice_set_id?
        field.save!
      end
    end
  end
end
