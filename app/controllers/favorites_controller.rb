class FavoritesController < ApplicationController
  FavoriteInvalid = Class.new(RuntimeError)
  respond_to :html, :js
  before_action :authenticate_user!

  rescue_from FavoriteInvalid do |exception|
    status = 400
    error = {
      :status => status,
      :error => "Bad request",
      :message => exception.message
    }
    render(:json => error, :status => status)
  end

  def index
    @list = ItemList::FavoriteResult.new(
      :current_user => current_user,
      :page => params[:page]
    )
  end

  def create
    build_favorite
    authorize(@favorite)
    item = find_item(params[:id])
    Favorite.create(item: item, user: current_user)
    redirect_to :back
  end

  def destroy
    find_favorite(params[:id])
    authorize(@favorite)
    @favorite.destroy
    redirect_to :back
  end

  def user_scoped?
    true
  end

  def favorites_scoped?
    true
  end

  private

  def build_favorite
    @favorite = Favorite.new
  end

  def find_item(item_id)
    Item.find_by(id: item_id)
  end

  def find_favorite(item_id)
    @favorite = Favorite.find_by(item_id: item_id, user_id: current_user)
  end
end
