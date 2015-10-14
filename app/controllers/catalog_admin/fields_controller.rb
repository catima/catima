class CatalogAdmin::FieldsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup"
  before_action :find_item_type

  def index
    authorize(@item_type, :show?)
    @fields = @item_type.fields.sorted
  end

  private

  def find_item_type
    @item_type = \
      catalog.item_types.where(:slug => params[:item_type_slug]).first!
  end
end
