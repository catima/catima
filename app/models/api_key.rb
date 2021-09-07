require 'securerandom'

class APIKey < ApplicationRecord
  belongs_to :catalog, optional: true

  validates :label, uniqueness: { scope: :catalog_id }

  has_secure_token :api_key, length: 256
end
