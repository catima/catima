class API::V3::Catalog::UsersController < API::V3::Catalog::BaseController
  include CatalogAdmin::CatalogsHelper

  after_action -> { set_pagination_header(:users) }, only: :index

  def index
    authorize(@catalog, :users_index?) unless authenticated_catalog?

    # Get all roles a user can have for a catalog with rights above the default role.
    catalog_roles = CatalogPermission::ROLE_OPTIONS[1..]

    # Get every user with rights, or belongs to a group with rights, above the
    # default role. The default role is not considered because it is assigned
    # to every user in each catalog.
    @users = User.where(id: @catalog.users_with_role_in(catalog_roles))
                 .or(User.where(id: @catalog.groups.where(active: true).select do |g|
                   case catalog_access(@catalog)
                   when CatalogAdmin::CatalogsHelper::CATALOG_ACCESS[:open_for_everyone]
                     true
                   when CatalogAdmin::CatalogsHelper::CATALOG_ACCESS[:open_to_members]
                     g.catalog_permissions.last.role_at_least?("member")
                   else
                     g.catalog_permissions.last.role_at_least?("editor")
                   end
                 end.flat_map(&:user_ids)))
                 .page(params[:page]).per(params[:per])
  end
end
