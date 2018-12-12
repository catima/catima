class API::V2::AdvancedSearchController < ActionController::Base
  include ControlsCatalog

  def index
    @search = ItemList::SimpleSearchResult.new(
      :catalog => catalog,
      :query => params[:q],
      :page => params[:page],
      :item_type_slug => params[:type]
    )
  end
end
