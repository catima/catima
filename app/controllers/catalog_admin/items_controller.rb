class CatalogAdmin::ItemsController < CatalogAdmin::BaseController
  include ControlsItemSorting
  before_action :find_item_type
  layout "catalog_admin/data/form"

  def index
    @items = apply_sort(policy_scope(item_scope))
    @items = @items.page(params[:page]).per(25)
    @fields = @item_type.all_list_view_fields
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
    redirect_to({ :action => "index" }, :notice => deleted_message)
  end

  private

  attr_reader :item_type

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
    params.require(:item).permit(
      :submit_for_review,
      *@item.data_store_permitted_attributes,
      *@item.fields.flat_map(&:custom_item_permitted_attributes)
    )
  end

  def after_create_path
    case params[:commit]
    when /another/i then { :action => "new" }
    else { :action => "index" }
    end
  end

  %w(created updated deleted).each do |verb|
    define_method("#{verb}_message") do
      "#{@item_type.name} “#{view_context.item_display_name(@item)}” "\
      "has been #{verb}."
    end
  end
end
