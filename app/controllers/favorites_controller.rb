class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @list = ItemList::FavoriteResult.new(
      :current_user => current_user,
      :page => params[:page]
    )
  end

  def user_scoped?
    true
  end
end
