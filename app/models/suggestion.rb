class Suggestion < ApplicationRecord
  belongs_to :catalog
  belongs_to :item_type
  belongs_to :item
  belongs_to :user, optional: true

  scope :ordered, -> { order(processed_at: :desc, created_at: :desc) }

  def process
    touch(:processed_at)
  end
end
