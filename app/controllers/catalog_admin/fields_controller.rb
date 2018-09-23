class CatalogAdmin::FieldsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup/form"
  before_action :find_field_set

  def index
    authorize(@field_set, :show?)
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
      respond_to do |f|
        f.js
        f.html do
          redirect_to({ :action => "index" }, :notice => updated_message)
        end
      end
    else
      render("edit")
    end
  end

  def destroy
    find_field
    authorize(@field)
    @field.destroy
    redirect_to({ :action => "index" }, :notice => destroyed_message)
  end

  private

  def fields
    @fields = @field_set.fields
  end
  helper_method :fields

  def build_field
    @field = field_class.new(:field_set => @field_set)
  end

  def field_class
    Field::TYPES.fetch(params[:type], "Field::Text").constantize
  end

  def find_field
    @field = @field_set.fields.where(:slug => params[:slug]).first!
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
      :display_in_public_list,
      :restricted,
      :i18n,
      :row_order_position,
      :editor_component,
      :display_component,
      *@field.custom_field_permitted_attributes
    )
  end

  def find_field_set
    @field_set = \
      if params[:item_type_slug]
        catalog.item_types.where(:slug => params[:item_type_slug]).first!
      else
        catalog.categories.find(params[:category_id])
      end
  end

  def created_message
    "The “#{@field.name}” field has been created."
  end

  def updated_message
    "The “#{@field.name}” field has been saved."
  end

  def destroyed_message
    "The “#{@field.name}” field has been deleted."
  end
end
