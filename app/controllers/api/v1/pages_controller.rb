class API::V1::PagesController < ActionController::Base
  def index
    render(:json => pages_scope)
  end

  def show
    render(:json => pages_scope.find(params[:id]))
  end

  private

  def pages_scope
    load_catalog.pages
  end

  def load_catalog
    Catalog.active.where(:slug => params[:catalog_slug]).first!
  end
end
