class API::V3::Catalog::CategoriesController < API::V3::Catalog::BaseController

  after_action -> { set_pagination_header(:categories) }, only: :index

  def index
    authorize(@catalog, :categories_index?)

    @categories = @catalog.categories.page(params[:page]).per(params[:per])
  end
end
