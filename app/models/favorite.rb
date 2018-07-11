# == Schema Information
#
# Table name: favorites
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  item_id    :integer
#  updated_at :datetime         not null
#  user_id    :integer
#

class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :item

  validates_presence_of :user
  validates_presence_of :item
end
