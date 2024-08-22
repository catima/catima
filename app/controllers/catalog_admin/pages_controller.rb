class CatalogAdmin::PagesController < CatalogAdmin::BaseController
  layout "catalog_admin/setup"
  include ControlsItemSorting

  attr_reader :item_type

  def index
    authorize(Page)
    @pages = catalog.pages.sorted
  end

  def new
    build_page
    authorize(@page)
  end

  def edit
    find_page
    authorize(@page)
  end

  def create
    build_page
    authorize(@page)
    if @page.update(page_params)
      redirect_to(after_create_path, :notice => created_message)
    else
      render("new")
    end
  end

  def update
    find_page
    authorize(@page)
    if @page.update(page_params)
      redirect_to(catalog_admin_pages_path, :notice => updated_message)
    else
      render("edit")
    end
  end

  def destroy
    find_page
    authorize(@page)
    if @page.id == catalog.custom_root_page_id
      redirect_to(catalog_admin_pages_path, :alert => error_message)
    else
      @page.destroy
      redirect_to(catalog_admin_pages_path, :notice => destroyed_message)
    end
  end

  def sort_field_select_options
    @item_type = catalog.item_types.find(params[:item_type_id])
    @fields = @item_type.fields.select(&:groupable?)
    render 'catalog_admin/containers/item_list/sort_field_select_options', layout: false
  end

  private

  def build_page
    @page = catalog.pages.new do |model|
      model.creator = current_user
    end
  end

  def find_page
    @page = catalog.pages.where(:slug => params[:slug]).first!
  end

  def page_params
    params.require(:page).permit(:slug, :title)
  end

  def created_message
    "Page “#{@page.slug}” has been created."
  end

  def updated_message
    "Page “#{@page.slug}” has been saved."
  end

  def destroyed_message
    "Page “#{@page.slug}” has been deleted."
  end

  def error_message
    "The page “#{@page.slug}” is the custom root page of this catalog. You cannot delete it."
  end

  def after_create_path
    case params[:commit]
    when /another/i then new_catalog_admin_page_path
    else catalog_admin_pages_path(catalog, I18n.locale)
    end
  end
end
