class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to(:back) if current_user.blank?
    @items = items(current_user.favorites)
  end

  def items(favorites)
    favorites.map(&:item)
  end

  def users(favorites)
    favorites.map(&:user)
  end

  def user_scoped?
    true
  end
end
