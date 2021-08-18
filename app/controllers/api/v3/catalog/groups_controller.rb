class API::V3::Catalog::GroupsController < API::V3::Catalog::BaseController
  after_action -> { set_pagination_header(:groups) }, only: :index

  def index
    authorize(@catalog, :groups_index?) unless authenticated_catalog?

    @groups = @catalog.groups.page(params[:page]).per(params[:per])
  end
end
