class SearchesController < ApplicationController
  before_action :authenticate_user!

  def show
    find_search(params[:id])

    if @search.related_search_type == SimpleSearch.name
      redirect_to simple_search_path(@search.catalog, I18n.locale, :uuid => @search.related_search.uuid)
    else
      redirect_to advanced_search_path(@search.catalog, :uuid => @search.related_search.uuid)
    end
  end

  def index
    @selected_catalog = find_catalog(params[:catalog])
    @list = ItemList::SavedSearch.new(:user => current_user)
    @catalogs = catalogs(@list)
  end

  def create
    related_search = find_related_search(params[:related_search_uuid])
    build_search(related_search)
    authorize(@search)
    Search.create(related_search: related_search, user: current_user)
    redirect_back fallback_location: searches_path
  end

  def edit
    find_search(params[:id])
    authorize(@search)
  end

  def update
    find_search(params[:id])
    authorize(@search)
    if @search.update(search_params)
      redirect_to searches_path, notice: updated_message
    else
      render 'edit'
    end
  end

  def destroy
    find_search(params[:id])
    authorize(@search)

    search_in_use = Container.where("content->>'search' = ?", @search.uuid).count.positive?
    return redirect_back fallback_location: searches_path, notice: I18n.t('searches.index.in_use') if search_in_use

    @search.destroy
    redirect_back fallback_location: searches_path
  end

  def user_scoped?
    true
  end

  def searches_scoped?
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

  def search_params
    params.require(:search).permit(:name)
  end

  def updated_message
    "Search “#{@search.name}” has been saved."
  end
end
