# == Schema Information
#
# Table name: api_keys
#
#  id         :bigint           not null, primary key
#  api_key    :string           not null
#  label      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  catalog_id :bigint
#
# Indexes
#
#  index_api_keys_on_api_key     (api_key)
#  index_api_keys_on_catalog_id  (catalog_id)
#
# Foreign Keys
#
#  fk_rails_...  (catalog_id => catalogs.id)
#
require 'securerandom'

class APIKey < ApplicationRecord
  belongs_to :catalog, optional: true

  validates :label, uniqueness: { scope: :catalog_id }

  before_create :generate_api_key

  private

  def generate_api_key
    self.api_key = SecureRandom.alphanumeric(256)
  end
end
