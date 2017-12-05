class CatalogAdmin::ItemViewsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup/form"
  before_action :find_item_type

  def new
    build_item_view
    authorize(@item_view)
  end

  def create
    build_item_view
    authorize(@item_view)
    if @item_view.update(item_view_params)
      redirect_to(
        catalog_admin_item_type_fields_path(@item_type.catalog, @item_type),
        notice: created_message)
    else
      render("new")
    end
  end

  def edit
    find_item_view
    authorize(@item_view)
  end

  def update
    find_item_view
    authorize(@item_view)
    if @item_view.update(item_view_params)
      respond_to do |f|
        f.js
        f.html do
          redirect_to(
            catalog_admin_item_type_fields_path(@item_type.catalog, @item_type),
            notice: updated_message)
        end
      end
    else
      render("edit")
    end
  end

  def destroy
    find_item_view
    authorize(@item_view)
    @item_view.destroy
    redirect_to(
      catalog_admin_item_type_fields_path(@item_type.catalog, @item_type),
      notice: destroyed_message)
  end

  private

  def find_item_type
    @item_type = ItemType.where(:slug => params[:item_type_slug]).first!
  end

  def build_item_view
    @item_view = @item_type.item_views.new
  end

  def find_item_view
    @item_view = ItemView.where(id: params[:id], item_type_id: @item_type.id).first!
  end

  def item_view_params
    params.require(:item_view).permit(
      :name,
      :default_for_item_view,
      :default_for_list_view,
      :default_for_display_name,
      :template
    )
  end

  def created_message
    "The “#{@item_view.name}” item view has been created."
  end

  def updated_message
    "The “#{@item_view.name}” item view has been saved."
  end

  def destroyed_message
    "The “#{@item_view.name}” item view has been deleted."
  end
end
