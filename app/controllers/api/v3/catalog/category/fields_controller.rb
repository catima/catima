class API::V3::Catalog::Category::FieldsController < API::V3::Catalog::Category::BaseController
  def index
    @fields = @category.fields.page(params[:page] || 1).per(params[:per] || 25)
  end
end
