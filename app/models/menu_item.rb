# == Schema Information
#
# Table name: menu_items
#
#  catalog_id   :integer
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  item_type_id :integer
#  page_id      :integer
#  parent_id    :integer
#  rank         :integer
#  slug         :string
#  title        :string
#  updated_at   :datetime         not null
#  url          :text
#

class MenuItem < ActiveRecord::Base
  belongs_to :catalog
  belongs_to :item_type
  belongs_to :page

  validates_presence_of :catalog
  validates_presence_of :title


  def self.sorted
    order("menu_items.rank ASC")
  end
end
