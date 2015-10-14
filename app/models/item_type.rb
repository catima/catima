# == Schema Information
#
# Table name: item_types
#
#  catalog_id  :integer
#  created_at  :datetime         not null
#  id          :integer          not null, primary key
#  name        :string
#  name_plural :string
#  slug        :string
#  updated_at  :datetime         not null
#

class ItemType < ActiveRecord::Base
  include HasSlug

  belongs_to :catalog
  has_many :fields

  validates_presence_of :catalog
  validates_presence_of :name
  validates_presence_of :name_plural
  validates_slug :scope => :catalog_id

  def self.sorted
    order("LOWER(item_types.name) ASC")
  end
end
