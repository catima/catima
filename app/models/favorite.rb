# == Schema Information
#
# Table name: favorites
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  item_id    :integer
#  user_id    :integer
#
# Indexes
#
#  index_favorites_on_item_id  (item_id)
#  index_favorites_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => items.id)
#  fk_rails_...  (user_id => users.id)
#

class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :item

  validates_presence_of :user
  validates_presence_of :item
end
