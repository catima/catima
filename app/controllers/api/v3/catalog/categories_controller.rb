class API::V3::Catalog::CategoriesController < API::V3::Catalog::BaseController
  def index
    @categories = @catalog.categories.page(params[:page] || 1).per(params[:per] || 25)
  end
end
