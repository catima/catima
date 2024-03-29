class API::V3::Catalog::Category::FieldsController < API::V3::Catalog::Category::BaseController
  after_action -> { set_pagination_header(:fields) }, only: :index

  def index
    authorize(@catalog, :category_fields_index?) unless authenticated_catalog?

    @fields = @category.fields
    @fields = @fields.where(restricted: false) unless authenticated_catalog? || @current_user.catalog_role_at_least?(@catalog, "editor")
    @fields = @fields.page(params[:page]).per(params[:per])
  end
end
