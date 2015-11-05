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

# Note: This is the ActiveRecord model for storing advanced search criteria.
# The actual logic for performing advanced searches is in a separate class
# called Search::Advanced.
#
class AdvancedSearch < ActiveRecord::Base
  belongs_to :catalog
  belongs_to :creator, :class_name => "User"
  belongs_to :item_type

  validates_presence_of :catalog
  validates_presence_of :item_type

  before_create :assign_uuid

  def to_param
    uuid
  end

  private

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
