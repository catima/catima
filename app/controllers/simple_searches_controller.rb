class SimpleSearchesController < ApplicationController
  include ControlsCatalog

  def show
    find_simple_search_or_redirect
    return redirect_to(catalog_home_path) if @saved_search.nil?

    @simple_search_results = ItemList::SimpleSearchResult.new(
      :catalog => catalog,
      :query => @saved_search.query,
      :page => params[:page],
      :item_type_slug => params[:type],
      :search_uuid => @saved_search.uuid
    )
  end

  def new
    build_simple_search

    return render("show") if simple_search_params.blank?

    # Legacy search
    build_simple_search
    if @saved_search.update(simple_search_params)
      redirect_to(:action => :show, :uuid => @saved_search.uuid)
    else
      render("new")
    end
  end

  def create
    build_simple_search
    if @saved_search.update(simple_search_params)
      redirect_to(:action => :show, :uuid => @saved_search.uuid)
    else
      render("new")
    end
  end

  protected

  def track
    # Log event only for the show action to avoid duplicates
    track_event("catalog_front") if params[:action].eql? 'show'
  end

  private

  def build_simple_search
    @saved_search = scope.new do |model|
      model.creator = current_user if current_user.authenticated?
    end
  end

  def find_simple_search_or_redirect
    @saved_search = SimpleSearch.find_by(:uuid => params[:uuid])
  end

  def simple_search_params
    params.permit(:q)
  end

  def scope
    catalog.simple_searches
  end
end
