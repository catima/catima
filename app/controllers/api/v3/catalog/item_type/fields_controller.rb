class API::V3::Catalog::ItemType::FieldsController < API::V3::Catalog::ItemType::BaseController
  def index
    @fields = @item_type.fields.page(params[:page]).per(params[:per] || DEFAULT_PAGE_SIZE)
  end

  def show
    @field = @item_type.fields.find(params[:field_id])
  end
end
