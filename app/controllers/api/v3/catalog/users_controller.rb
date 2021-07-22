class API::V3::Catalog::UsersController < API::V3::Catalog::BaseController
  after_action -> { set_pagination_header(:users) }, only: :index

  def index
    authorize(@catalog,:users_index?)

    @users = User.where(id: @catalog.user_with_role_in(%w[member editor super-editor reviewer admin])).page(params[:page]).per(params[:per])
  end
end
