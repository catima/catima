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
