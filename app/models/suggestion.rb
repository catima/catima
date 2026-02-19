# == Schema Information
#
# Table name: suggestions
#
#  id           :bigint           not null, primary key
#  content      :text
#  processed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  catalog_id   :bigint           not null
#  item_id      :bigint           not null
#  item_type_id :bigint           not null
#  user_id      :bigint
#
# Indexes
#
#  index_suggestions_on_catalog_id    (catalog_id)
#  index_suggestions_on_item_id       (item_id)
#  index_suggestions_on_item_type_id  (item_type_id)
#  index_suggestions_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (catalog_id => catalogs.id)
#  fk_rails_...  (item_id => items.id)
#  fk_rails_...  (item_type_id => item_types.id)
#  fk_rails_...  (user_id => users.id)
#
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
