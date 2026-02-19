# == Schema Information
#
# Table name: advanced_searches
#
#  id                               :integer          not null, primary key
#  criteria                         :json
#  locale                           :string           default("en"), not null
#  uuid                             :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  advanced_search_configuration_id :bigint
#  catalog_id                       :integer
#  creator_id                       :integer
#  item_type_id                     :integer
#
# Indexes
#
#  index_advanced_searches_on_advanced_search_configuration_id  (advanced_search_configuration_id)
#  index_advanced_searches_on_catalog_id                        (catalog_id)
#  index_advanced_searches_on_item_type_id                      (item_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (advanced_search_configuration_id => advanced_search_configurations.id)
#  fk_rails_...  (catalog_id => catalogs.id)
#  fk_rails_...  (item_type_id => item_types.id)
#

# NOTE: This is the ActiveRecord model for storing advanced search criteria.
# The actual logic for performing advanced searches is in a separate class
# called ItemList::AdvancedSearchResult.
#
class AdvancedSearch < ApplicationRecord
  delegate :fields, :to => :item_type
  delegate :item_types, :to => :catalog

  belongs_to :catalog
  belongs_to(
    :creator,
    -> { unscope(where: :deleted_at) },
    :class_name => "User",
    inverse_of: :advanced_searches,
    optional: true
  )
  belongs_to :item_type, -> { not_deleted }
  belongs_to :advanced_search_configuration, optional: true

  has_one :search, :as => :related_search, dependent: :destroy

  validates_presence_of :catalog
  validates_presence_of :item_type

  before_create :assign_locale
  before_create :assign_uuid

  attr_accessor :field_condition, :exclude_condition

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
