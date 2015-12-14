class CatalogAdmin::CategoriesController < CatalogAdmin::BaseController
  layout "catalog_admin/setup/form"

  def index
    # Redirect to the first category if one exists.
    # Otherwise redirect to the default admin URL.
    first_category = catalog.categories.first
    return redirect_to(catalog_admin_setup_path) if first_category.nil?
    redirect_to(catalog_admin_category_fields_path(catalog, first_category))
  end

  def new
    build_category
    authorize(@category)
  end

  def create
    build_category
    authorize(@category)
    if @category.update(category_params)
      redirect_to(after_create_path, :notice => created_message)
    else
      render("new")
    end
  end

  def edit
    find_category
    authorize(@category)
  end

  def update
    find_category
    authorize(@category)
    if @category.update(category_params)
      redirect_to(
        catalog_admin_category_fields_path(catalog, @category),
        :notice => updated_message
      )
    else
      render("edit")
    end
  end

  def destroy
    find_category
    authorize(@category)
    @category.update!(:deactivated_at => Time.current)
    redirect_to({ :action => "index" }, :notice => deleted_message)
  end

  private

  def build_category
    @category = catalog.categories.new
  end

  def find_category
    @category = catalog.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end

  def after_create_path
    case params[:commit]
    when /another/i then new_catalog_admin_category_path
    else catalog_admin_category_fields_path(catalog, @category)
    end
  end

  %w(created updated deleted).each do |verb|
    define_method("#{verb}_message") do
      "The “#{@category.name}” category has been #{verb}."
    end
  end
end
