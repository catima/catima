# == Schema Information
#
# Table name: simple_searches
#
#  catalog_id :bigint(8)
#  created_at :datetime         not null
#  creator_id :integer
#  id         :bigint(8)        not null, primary key
#  locale     :string           default("en"), not null
#  query      :string
#  updated_at :datetime         not null
#  uuid       :string
#

class SimpleSearch < ApplicationRecord
  belongs_to :catalog
  belongs_to(
    :creator,
    -> { unscope(where: :deleted_at) },
    :class_name => "User",
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
