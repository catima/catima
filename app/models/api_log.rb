class APILog < ApplicationRecord
  belongs_to :user
  belongs_to :catalog, optional: true

  scope :ordered, -> { order(created_at: :desc) }
end
