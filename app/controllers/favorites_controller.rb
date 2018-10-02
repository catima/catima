class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @selected_catalog = find_catalog(params[:catalog])
    @list = ItemList::FavoriteResult.new(
      :current_user => current_user,
      :selected_catalog => @selected_catalog,
      :page => params[:page]
    )
    @catalogs = catalogs(@list)
  end

  def create
    item = find_item(params[:id])
    build_favorite(item)
    authorize(@favorite)
    Favorite.create(item: item, user: current_user)
    redirect_back fallback_location: favorites_path
  end

  def destroy
    find_favorite(params[:id])
    authorize(@favorite)
    @favorite.destroy
    redirect_back fallback_location: favorites_path
  end

  def user_scoped?
    true
  end

  def favorites_scoped?
    true
  end

  private

  def build_favorite(item)
    @favorite = Favorite.new do |model|
      model.item = item
      model.user = current_user
    end
  end

  def find_item(item_id)
    Item.find_by(id: item_id)
  end

  def find_favorite(item_id)
    @favorite = Favorite.find_by(item_id: item_id, user_id: current_user)
  end

  def find_catalog(catalog_id)
    return nil if catalog_id.blank?
    return nil unless /^\d+$/ =~ catalog_id

    Catalog.find(catalog_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def catalogs(list)
    return nil if list.blank?
    return nil if @selected_catalog

    catalogs = list.items.each_with_object([]) do |item, array|
      array << item.catalog
    end
    catalogs.group_by(&:itself).map { |k, v| [k, v.count] }
  end
end
