class API::V3::Catalog::ItemType::FieldsController < API::V3::Catalog::ItemType::BaseController
  before_action :find_fields
  after_action -> { set_pagination_header(:fields) }, only: :index

  def index
    authorize(@catalog, :item_type_fields_index?) unless authenticated_catalog?

    @fields = @fields.page(params[:page]).per(params[:per])
  end

  def show
    authorize(@catalog, :item_type_field_show?)

    @field = @fields.find(params[:field_id])
  end

  private

  def find_fields
    @fields = @item_type.fields
    @fields = @fields.where(restricted: false) unless @current_user.catalog_role_at_least?(@catalog, "editor")
  end
end
