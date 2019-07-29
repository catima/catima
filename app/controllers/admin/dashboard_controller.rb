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
    raise Pundit::NotAuthorizedError unless current_user.system_admin?

    authorize(Catalog, :index?)
    authorize(User, :index?)

    @scope = stats_scope
    @from = 3.months
    @top = 5
  end

  private

  # Retrieve users for index with pagination & search params
  def index_users(search=nil, page=1)
    users = User.sorted
    users = users.search(search) if search
    users.page(page)
  end

  # Retrieve scope parameter for the stats view
  def stats_scope
    redirect_to admin_dashboard_path, alert: "Scope not available" unless
        params[:scope].present? && %w(catalogs).include?(params[:scope])

    params[:scope]
  end
end
