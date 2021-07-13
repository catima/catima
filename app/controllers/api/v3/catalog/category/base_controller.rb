class API::V3::Catalog::Category::BaseController < API::V3::Catalog::BaseController
  before_action :find_category

  private

  def find_category
    @category = @catalog.categories.find(params[:category_id])
  end
end
