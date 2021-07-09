class API::V3::Catalog::CategoriesController < API::V3::Catalog::BaseController
  def index
    @categories = @catalog.categories.page(params[:page] ).per(params[:per] || DEFAULT_PAGE_SIZE)
  end
end
