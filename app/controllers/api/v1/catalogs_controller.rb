class API::V1::CatalogsController < ActionController::Base
  def index
    render(:json => API::V1::PaginationSerializer.new(
      "catalogs", catalogs_scope, params
    ))
  end

  def show
    catalog = catalogs_scope.where(:slug => params[:slug]).first!
    render(:json => catalog)
  end

  private

  def catalogs_scope
    Catalog.active
  end
end
