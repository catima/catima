class Admin::DashboardController < Admin::BaseController
  def index
    if current_user.system_admin?
      authorize(Catalog, :index?)
      authorize(User, :index?)

      @users = User.sorted
      @catalogs = Catalog.sorted
      @configuration = ::Configuration.first!
      @template_storages = TemplateStorage.all
    else
      @catalogs = Catalog.sorted.select do |catalog|
        catalog_access = current_user.catalog_role_at_least? catalog, "editor"
        authorize(catalog, :show?) if catalog_access
        catalog_access
      end
    end
  end
end
