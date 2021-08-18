require 'securerandom'

class APIKey < ApplicationRecord
  belongs_to :catalog, optional: true

  validates :label, uniqueness: { scope: :catalog_id }

  has_secure_token :api_key

  scope :revoked, -> { where(revoked: true) }
  scope :active, -> { where(revoked: false) }

  def revoke
    self.revoked = true
    save
  end
end
