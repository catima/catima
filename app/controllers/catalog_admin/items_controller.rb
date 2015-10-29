class CatalogAdmin::ItemsController < CatalogAdmin::BaseController
  before_action :find_item_type
  layout "catalog_admin/data/form"

  # TODO: arbitrary sorting
  # TODO: pagination
  def index
    @items = policy_scope(item_scope).sorted_by_field(@item_type.primary_field)
    @fields = @item_type.list_view_fields
    render("index", :layout => "catalog_admin/data")
  end

  def show
    find_item
    authorize(@item)
  end

  def new
    build_item
    authorize(@item)
  end

  def create
    build_item
    authorize(@item)
    if @item.update(item_params)
      redirect_to(after_create_path, :notice => created_message)
    else
      render("new")
    end
  end

  def edit
    find_item
    authorize(@item)
  end

  def update
    find_item
    authorize(@item)
    if @item.update(item_params)
      redirect_to({ :action => "index" }, :notice => updated_message)
    else
      render("edit")
    end
  end

  def destroy
    find_item
    authorize(@item)
    @item.destroy
    redirect_to({ :action => "index" }, :notice => destroyed_message)
  end

  private

  def find_item_type
    @item_type = catalog.item_types
                 .where(:slug => params[:item_type_slug])
                 .first!
  end

  def item_scope
    catalog.items_of_type(@item_type)
  end

  def find_item
    @item = item_scope.find(params[:id]).behaving_as_type
  end

  def build_item
    @item = @item_type.items.new.tap do |item|
      item.catalog = catalog
      item.creator = current_user
    end.behaving_as_type
  end

  def item_params
    params.require(:item).permit(*@item.data_store_attributes)
  end

  def after_create_path
    case params[:commit]
    when /another/i then { :action => "new" }
    else { :action => "index" }
    end
  end

  def created_message
    "#{@item_type.name} “#{@item.display_name}” has been created."
  end

  def updated_message
    "#{@item_type.name} “#{@item.display_name}” has been saved."
  end

  def destroyed_message
    "#{@item_type.name} “#{@item.display_name}” has been deleted."
  end
end
