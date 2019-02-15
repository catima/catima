class SimpleSearchController < ApplicationController
  include ControlsCatalog

  def new
    build_simple_search
  end

  def create
    build_simple_search
    if @simple_search.update(simple_search_params)
      redirect_to(:action => :index, :uuid => @simple_search.uuid)
    else
      render("new")
    end
  end

  def index
    find_simple_search_or_redirect
    @simple_search_result = ItemList::SimpleSearchResult.new(
      :catalog => catalog,
      :query => @simple_search.query,
      :page => params[:page],
      :item_type_slug => params[:type]
    )
  end

  private

  def build_simple_search
    # type = catalog.item_types.where(:slug => params[:type]).first
    @simple_search = scope.new do |model|
      # model.item_type = type || catalog.item_types.sorted.first
      model.creator = current_user if current_user.authenticated?
    end
  end

  def find_simple_search_or_redirect
    @simple_search = SimpleSearch.find_by(:uuid => params[:uuid])
    redirect_to(catalog_home_path) if @simple_search.nil?
  end

  def simple_search_params
    # search = ItemList::Search.new(
    #   :current_user => current_user,
    #   :selected_catalog => @simple_search.catalog
    # )
    # search.permit_criteria(params.permit(:q))

    params.permit(:q)
  end

  def scope
    catalog.simple_searches
  end
end
