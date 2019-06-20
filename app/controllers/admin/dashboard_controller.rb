class Admin::DashboardController < Admin::BaseController
  def index
    if current_user.system_admin?
      authorize(Catalog, :index?)
      authorize(User, :index?)

      @users = index_users(params[:search], params[:page])
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

    return unless @catalogs.empty?

    redirect_to edit_user_registration_path(locale: I18n.locale)
    skip_authorization
  end

  def stats
    if current_user.system_admin?
      authorize(Catalog, :index?)

      @scope = params[:scope]
      @from = 3.months.ago
      @top = 5
    else
      redirect_to admin_dashboard_path
    end
  end

  private

  # Retrieve users for index with pagination & search params
  def index_users(search=nil, page=1)
    users = User.sorted
    users = users.search(search) if search
    users.page(page)
  end
end
