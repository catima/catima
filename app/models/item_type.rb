# == Schema Information
#
# Table name: item_types
#
#  catalog_id      :integer
#  created_at      :datetime         not null
#  id              :integer          not null, primary key
#  name            :json
#  name_old        :string
#  name_plural     :json
#  name_plural_old :string
#  slug            :string
#  updated_at      :datetime         not null
#

# TODO: drop name_old and name_plural_old columns (no longer used)
class ItemType < ActiveRecord::Base
  include HasI18nNames
  include HasSlug

  belongs_to :catalog

  has_many :fields, -> { sorted }
  has_many :list_view_fields,
           -> { where(:display_in_list => true).sorted },
           :class_name => "Field"

  has_many :items

  validates_presence_of :catalog
  validates_slug :scope => :catalog_id

  def self.sorted
    order("LOWER(item_types.name) ASC")
  end

  def primary_field
    fields.where(:primary => true).first
  end

  def sorted_items
    items.sorted_by_field(primary_field)
  end
end
