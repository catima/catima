# == Schema Information
#
# Table name: advanced_searches
#
#  catalog_id   :integer
#  created_at   :datetime         not null
#  creator_id   :integer
#  criteria     :json
#  id           :integer          not null, primary key
#  item_type_id :integer
#  updated_at   :datetime         not null
#  uuid         :string
#

class AdvancedSearch < ActiveRecord::Base
  belongs_to :item_type
  belongs_to :catalog
end
