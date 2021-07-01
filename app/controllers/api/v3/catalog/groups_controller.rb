class API::V3::Catalog::GroupsController < API::V3::Catalog::BaseController
  def index
    authorize(@catalog)
    @groups = @catalog.groups.page(params[:page] || 1).per(params[:per] || 25)
  end
end
