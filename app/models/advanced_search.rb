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
#  locale       :string           default("en"), not null
#  updated_at   :datetime         not null
#  uuid         :string
#

# Note: This is the ActiveRecord model for storing advanced search criteria.
# The actual logic for performing advanced searches is in a separate class
# called ItemList::AdvancedSearchResult.
#
class AdvancedSearch < ActiveRecord::Base
  delegate :fields, :to => :item_type
  delegate :item_types, :to => :catalog

  belongs_to :catalog
  belongs_to :creator, :class_name => "User"
  belongs_to :item_type, -> { active }

  validates_presence_of :catalog
  validates_presence_of :item_type

  before_create :assign_locale
  before_create :assign_uuid

  def to_param
    uuid
  end

  private

  def assign_locale
    self.locale = I18n.locale
  end

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
