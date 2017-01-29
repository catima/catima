class API::V1::CatalogsController < ActionController::Base
  def index
  end

  def show
    catalog = load_catalog
    render(:json => catalog)
  end

  private

  def load_catalog
    Catalog.active.where(:slug => params[:slug]).first!
  end
end
