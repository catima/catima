class Admin::CatalogsController < Admin::BaseController
  layout "admin/form"

  def new
    build_catalog
  end

  def create
    build_catalog
    authorize(@catalog)
    if @catalog.update(catalog_params)
      redirect_to(admin_dashboard_path, :notice => created_message)
    else
      render("new")
    end
  end

  def edit
    find_catalog
    authorize(@catalog)
  end

  def update
    find_catalog
    authorize(@catalog)
    if @catalog.update(catalog_params)
      redirect_to(admin_dashboard_path, :notice => updated_message)
    else
      render("edit")
    end
  end

  private

  def build_catalog
    @catalog = Catalog.new
  end

  def find_catalog
    @catalog = Catalog.where(:slug => params[:slug]).first!
  end

  def catalog_params
    params.require(:catalog).permit(
      :name,
      :slug,
      :primary_language,
      :requires_review,
      :deactivated_at,
      :other_languages => []
    )
  end

  def created_message
    "The “#{@catalog.name}” catalog has been created."
  end

  def updated_message
    message = "The “#{@catalog.name}” catalog has been "
    if catalog_params.key?(:deactivated_at)
      message << (@catalog.active? ? "reactivated." : "deactivated.")
    else
      message << "updated."
    end
    message
  end
end
