class CatalogAdmin::FieldsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup/form"
  before_action :find_item_type

  def index
    authorize(@item_type, :show?)
    @fields = @item_type.fields
    render("index", :layout => "catalog_admin/setup")
  end

  def new
    build_field
    authorize(@field)
  end

  def create
    build_field
    authorize(@field)
    if @field.update(field_params)
      redirect_to({ :action => "index" }, :notice => created_message)
    else
      render("new")
    end
  end

  def edit
    find_field
    authorize(@field)
  end

  def update
    find_field
    authorize(@field)
    if @field.update(field_params)
      # TODO: support AJAX
      redirect_to({ :action => "index" }, :notice => updated_message)
    else
      render("edit")
    end
  end

  private

  def build_field
    @field = field_class.new(:item_type => @item_type)
  end

  def field_class
    Field::TYPES.fetch(params[:type], "Field::Text").constantize
  end

  def find_field
    @field = @item_type.fields.where(:slug => params[:slug]).first!
  end

  def field_params
    params.require(:field).permit(
      :name_de, :name_en, :name_fr, :name_it,
      :name_plural_de, :name_plural_en, :name_plural_fr, :name_plural_it,
      :slug,
      :comment,
      :style,
      :unique,
      :default_value,
      :primary,
      :display_in_list,
      :row_order_position,
      *@field.custom_permitted_attributes
    )
  end

  def find_item_type
    @item_type = \
      catalog.item_types.where(:slug => params[:item_type_slug]).first!
  end

  def created_message
    "The “#{@field.name}” field has been created."
  end

  def updated_message
    "The “#{@field.name}” field has been saved."
  end
end
