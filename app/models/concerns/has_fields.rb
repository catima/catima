# Common behavior for ItemType and Category models. Not STI.
module HasFields
  extend ActiveSupport::Concern

  included do
    belongs_to :catalog

    has_many :fields, -> { sorted }
    has_many :list_view_fields,
             -> { where(:display_in_list => true).sorted },
             :class_name => "Field"
    has_many :referenced_by_fields,
             :foreign_key => "related_item_type_id",
             :class_name => "Field"

    validates_presence_of :catalog
  end
end
