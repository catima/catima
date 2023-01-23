class Suggestion < ApplicationRecord
  belongs_to :catalog
  belongs_to :item_type
  belongs_to :item
  belongs_to(
    :user,
    -> { unscope(where: :deleted_at) },
    inverse_of: :suggestions,
    optional: true
  )

  scope :ordered, -> { order(processed_at: :desc, created_at: :desc) }

  validates_presence_of :content, allow_blank: false

  def process
    touch(:processed_at)
  end
end
