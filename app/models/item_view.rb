# == Schema Information
#
# Table name: item_views
#
#  created_at            :datetime         not null
#  default_for_item_view :boolean
#  default_for_list_view :boolean
#  id                    :integer          not null, primary key
#  item_type_id          :integer
#  name                  :string
#  template              :jsonb
#  updated_at            :datetime         not null
#

class ItemView < ActiveRecord::Base
  belongs_to :item_type

  validates_presence_of :item_type
  validates_presence_of :name
  validates_presence_of :template
end
