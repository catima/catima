# Common behavior for ItemType and Category models. Not STI.
module HasFields
  extend ActiveSupport::Concern

  included do
    belongs_to :catalog

    class_name = name

    has_many :fields,
             -> { where(:field_set_type => class_name).sorted },
             :foreign_key => :field_set_id

    has_many :list_view_fields,
             lambda {
               where(
                 :field_set_type => class_name,
                 :display_in_list => true
               ).sorted
             },
             :foreign_key => :field_set_id,
             :foreign_type => :field_set_type,
             :class_name => "Field"

    has_many :referenced_by_fields,
             :foreign_key => "related_item_type_id",
             :class_name => "Field"

    validates_presence_of :catalog
  end

  # An array of all fields in this field set, plus any nested fields included
  # by way of categories. Note that this could recurse forever given bad data,
  # so a recursion limit is imposed.
  def all_fields(max_depth=3)
    return [] if max_depth < 1
    fields.each_with_object([]) do |field, all|
      all << field
      next unless field.is_a?(Field::ChoiceSet)
      field.choices.each do |choice|
        all.concat(choice.category.all_fields(max_depth - 1)) if choice.category
      end
    end
  end

  # Same as all_fields, but limited to display_in_list=>true.
  def all_list_view_fields(max_depth=3)
    all_fields(max_depth).select(&:display_in_list)
  end
end
