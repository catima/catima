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
    item = find_item(params[:id])
    authorize(item)
    Favorite.create(item: item, user: current_user)
    redirect_to :back
  end

  def destroy
    item = find_item(params[:id])
    authorize(item)
    item.destroy
    redirect_to :back
  end

  def user_scoped?
    true
  end

  def favorites_scoped?
    true
  end

  private

  def find_item(item_id)
    Item.find_by(id: item_id)
  end
end
