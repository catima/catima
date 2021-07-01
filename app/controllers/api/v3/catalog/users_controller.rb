class API::V3::Catalog::UsersController < API::V3::Catalog::BaseController
  def index
    authorize(@catalog)
    @users = User.where(id: @catalog.user_with_role_in(["member", "editor", "super-editor", "reviewer", "admin"])).page(params[:page] || 1).per(params[:per] || 25)
  end
end
