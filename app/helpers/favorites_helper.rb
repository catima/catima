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

module FavoritesHelper
  def exists_for_user?(item)
    Favorite.exists?(:item => item, :user => current_user)
  end
end
