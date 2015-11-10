class CatalogAdmin::PagesController < CatalogAdmin::BaseController
  layout "catalog_admin/setup"

  # TODO: authorization

  def index
    # authorize(Page)
    @pages = catalog.pages.sorted
  end

  def new
    build_page
    # authorize(@page)
  end

  def create
    build_page
    # authorize(@page)
    if @page.update(page_params)
      redirect_to(after_create_path, :notice => created_message)
    else
      render("new")
    end
  end

  def edit
    find_page
    # authorize(@page)
  end

  def update
    find_page
    # authorize(@page)
    if @page.update(page_params)
      redirect_to(catalog_admin_pages_path, :notice => updated_message)
    else
      render("edit")
    end
  end

  def destroy
    find_page
    # authorize(@page)
    @page.destroy
    redirect_to(catalog_admin_pages_path, :notice => destroyed_message)
  end

  private

  def build_page
    @page = catalog.pages.new do |model|
      model.creator = current_user
      model.locale = catalog.primary_language
    end
  end

  def find_page
    @page = catalog.pages.where(:slug => params[:slug]).first!
  end

  def page_params
    params.require(:page).permit(:content, :locale, :slug, :title)
  end

  def created_message
    "Page “#{@page.title}” has been created."
  end

  def updated_message
    "Page “#{@page.title}” has been saved."
  end

  def destroyed_message
    "Page “#{@page.title}” has been deleted."
  end

  def after_create_path
    case params[:commit]
    when /another/i then new_catalog_admin_page_path
    else catalog_admin_pages_path(catalog)
    end
  end
end
