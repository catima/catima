class API::V3::Catalog::Category::FieldsController < API::V3::Catalog::Category::BaseController
  def index
    @fields = @category.fields.page(params[:page]).per(params[:per] || DEFAULT_PAGE_SIZE)
  end
end
