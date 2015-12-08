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
end
