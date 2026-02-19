# == Schema Information
#
# Table name: simple_searches
#
#  id         :bigint           not null, primary key
#  locale     :string           default("en"), not null
#  query      :string
#  uuid       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  catalog_id :bigint
#  creator_id :integer
#
# Indexes
#
#  index_simple_searches_on_catalog_id  (catalog_id)
#
# Foreign Keys
#
#  fk_rails_...  (catalog_id => catalogs.id)
#

class SimpleSearch < ApplicationRecord
  belongs_to :catalog
  belongs_to(
    :creator,
    -> { unscope(where: :deleted_at) },
    :class_name => "User",
    inverse_of: :simple_searches,
    optional: true
  )

  has_one :search, :as => :related_search, dependent: :destroy

  before_create :assign_locale
  before_create :assign_uuid

  # Maps the SimpleSearch column query with the :q search param.
  # Used for simple search legacy URLs.
  alias_attribute :q, :query

  private

  def assign_locale
    self.locale = I18n.locale
  end

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
