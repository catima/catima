# == Schema Information
#
# Table name: item_types
#
#  catalog_id :integer
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  label      :string
#  slug       :string
#  updated_at :datetime         not null
#

class ItemType < ActiveRecord::Base
  belongs_to :catalog

  validates_presence_of :catalog
  validates_presence_of :label
  validates_presence_of :slug
  validates_uniqueness_of :slug
end
