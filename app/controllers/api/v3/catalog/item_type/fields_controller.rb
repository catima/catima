class API::V3::Catalog::ItemType::FieldsController < API::V3::Catalog::ItemType::BaseController
  def index
    @fields = @item_type.fields.page(params[:page] || 1).per(params[:per] || 25)
  end

  def show
    @field = @item_type.fields.find(params[:field_id])
  end
end
