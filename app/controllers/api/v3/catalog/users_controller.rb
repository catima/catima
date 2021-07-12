class API::V3::Catalog::UsersController < API::V3::Catalog::BaseController
  def index
    authorize(@catalog)
    @users = User.where(id: @catalog.user_with_role_in(%w[member editor super-editor reviewer admin])).page(params[:page]).per(params[:per] || DEFAULT_PAGE_SIZE)
  end
end
