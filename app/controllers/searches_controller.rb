class SearchesController < ApplicationController
  before_action :authenticate_user!

  def show
    find_search(params[:id])
    
  end

  def index
    @selected_catalog = find_catalog(params[:catalog])
    @list = ItemList::Search.new(
      :current_user => current_user,
      :selected_catalog => @selected_catalog,
      :page => params[:page]
    )
    @catalogs = catalogs(@list)
  end

  def create
    related_search = find_related_search(params[:related_search_uuid])
    build_search(related_search)
    authorize(@search)
    Search.create(related_search: related_search, user: current_user)
    redirect_back fallback_location: searches_path
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

  def build_search(related_search)
    @search = ::Search.new do |model|
      model.related_search = related_search
      model.user = current_user
    end
  end

  def find_related_search(search_uuid)
    SimpleSearch.find_by(uuid: search_uuid).presence || AdvancedSearch.find_by(uuid: search_uuid)
  end

  def find_search(search_id)
    @search = Search.find_by(id: search_id, user_id: current_user)
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

    catalogs = list.unpaginaged_items.each_with_object([]) do |item, array|
      array << item.related_search.catalog
    end
    catalogs.group_by(&:itself).map { |k, v| [k, v.count] }
  end
end
