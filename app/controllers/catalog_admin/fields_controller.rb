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

  private

  def build_field
    @field = field_class.new(:item_type => @item_type)
  end

  def field_class
    Field::TYPES.fetch(params[:type], "Field::Text").constantize
  end

  def find_item_type
    @item_type = \
      catalog.item_types.where(:slug => params[:item_type_slug]).first!
  end
end
