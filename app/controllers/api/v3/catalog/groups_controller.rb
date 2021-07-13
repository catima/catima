class API::V3::Catalog::GroupsController < API::V3::Catalog::BaseController
  def index
    authorize(@catalog)
    @groups = @catalog.groups.page(params[:page]).per(params[:per] || DEFAULT_PAGE_SIZE)
  end
end
