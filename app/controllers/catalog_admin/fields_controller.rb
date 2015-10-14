class CatalogAdmin::FieldsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup/form"
  before_action :find_item_type

  def index
    authorize(@item_type, :show?)
    @fields = @item_type.fields.sorted
    render("index", :layout => "catalog_admin/setup")
  end

  def new
    build_field
    # TODO: authorize(@field)
  end

  def create
    build_field
    # TODO: authorize(@field)
    if @field.update(field_params)
      redirect_to({ :action => "index" }, :notice => created_message)
    else
      render("new")
    end
  end

  private

  def build_field
    @field = field_class.new(:item_type => @item_type)
  end

  def field_class
    Field::TYPES.fetch(params[:type], "Field::Text").constantize
  end

  def field_params
    params.require(@field.model_name.param_key).permit(
      :name,
      :name_plural,
      :slug,
      :comment,
      :style,
      :unique,
      :default_value,
      :position,
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
end
