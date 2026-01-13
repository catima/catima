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

    # Prepare data to avoid N+1 queries in the view
    @stats_all = prepare_stats_data(nil)
    @stats_admin = prepare_stats_data('catalog_admin')
    @stats_front = prepare_stats_data('catalog_front')
  end

  def download_stats
    raise Pundit::NotAuthorizedError unless current_user.system_admin?

    authorize(Catalog, :index?)
    authorize(User, :index?)

    send_data build_stats_export, filename: "#{Time.zone.today}_catima_stats.csv", type: "text/csv"
  end

  private

  def prepare_stats_data(scope_filter)
    # Retrieve top catalogs
    top_catalogs = Ahoy::Event.top(@top, @from, scope_filter)
    catalog_names = top_catalogs.map(&:first)

    return [] if catalog_names.empty?

    # Retrieve all data with a single optimized query
    from_date = @from.ago
    query = Ahoy::Event.select("name, DATE_TRUNC('week', time) as week, COUNT(*) as count")
                       .where(name: catalog_names)
                       .where("time > ?", from_date)

    query = query.where('properties @> ?', { scope: scope_filter }.to_json) if scope_filter

    grouped_data = query.group("name, week").order("week")

    # Organize data by catalog
    data_by_catalog = grouped_data.each_with_object(Hash.new { |h, k| h[k] = {} }) do |row, hash|
      hash[row.name][row.week] = row.count
    end

    # Format for line_chart
    catalog_names.map do |catalog_name|
      {
        name: catalog_name,
        data: data_by_catalog[catalog_name] || {}
      }
    end
  end

  def build_stats_export(from=Ahoy::Event.validity.ago)
    require 'csv'

    # Retrieve visits for each catalog
    data = Catalog.all.map do |catalog|
      monthly_counts = Ahoy::Event.where(name: catalog.slug)
                                  .where("time > ?", from)
                                  .group_by_month(:time)
                                  .count

      { name: catalog.name, data: monthly_counts }
    end

    # Extract unique months from the data, sort them, and store them in an array
    months = data.flat_map { |item| item[:data].keys }.uniq.sort
    # Create the CSV headers with "Catalog name" followed by the formatted month names
    headers = ["Catalog name"] + months.map { |d| d.strftime("%b %Y") }

    CSV.generate do |csv|
      csv << headers

      # Iterate over each item in the data to populate the CSV rows
      data.each do |item|
        # For each month, fetch the count from the item's data or use 0 if the month is missing
        counts = months.map { |month| item[:data].fetch(month, 0) }

        # Add the item's name and the counts as a new row in the CSV
        csv << ([item[:name]] + counts)
      end
    end
  end

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
