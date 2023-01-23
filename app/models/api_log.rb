class APILog < ApplicationRecord
  belongs_to :user, -> { unscope(where: :deleted_at) }, inverse_of: :api_logs
  belongs_to :catalog, optional: true

  scope :ordered, -> { order(created_at: :desc) }

  def self.validity
    ENV["API_LOGS_VALIDITY"].present? ? Integer(ENV["API_LOGS_VALIDITY"]).months : 4.months
  end
end
