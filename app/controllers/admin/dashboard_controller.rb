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

  def download_stats
    raise Pundit::NotAuthorizedError unless current_user.system_admin?

    authorize(Catalog, :index?)
    authorize(User, :index?)

    require 'csv'

    # Retrieve visits for each catalog
    data = Catalog.all.map do |catalog|
      catalog_slug = catalog.slug
      monthly_counts = Ahoy::Event.where(name: catalog_slug)
                                  .where("time > ?", Ahoy::Event.validity.ago)
                                  .group_by_month(:time)
                                  .count

      { name: catalog.name, data: monthly_counts }
    end

    # Extract unique months from the data, sort them, and store them in an array
    months = data.flat_map { |item| item[:data].keys }.uniq.sort
    # Create the CSV headers with "Catalog name" followed by the formatted month names
    headers = ["Catalog name"] + months.map { |d| d.strftime("%b %Y") }

    csv_output = CSV.generate do |csv|
      csv << headers

      # Iterate over each item in the data to populate the CSV rows
      data.each do |item|
        # For each month, fetch the count from the item's data or use 0 if the month is missing
        counts = months.map { |month| item[:data].fetch(month, 0) }

        # Add the item's name and the counts as a new row in the CSV
        csv << ([item[:name]] + counts)
      end
    end

    send_data csv_output, filename: "catima_stats_all.csv", type: "text/csv"
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
