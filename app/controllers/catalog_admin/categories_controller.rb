class CatalogAdmin::CategoriesController < CatalogAdmin::BaseController
  layout "catalog_admin/setup/form"

  # TODO: Pundit-based authorization
  #
  def new
    build_category
    # authorize(@category)
  end

  def create
    build_category
    # authorize(@category)
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

  def created_message
    "The “#{@category.name}” category has been created."
  end

  def updated_message
    "The “#{@category.name}” category has been updated."
  end
end
