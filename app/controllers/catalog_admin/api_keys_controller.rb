class CatalogAdmin::APIKeysController < CatalogAdmin::BaseController
  before_action :find_and_authorize_catalog
  before_action :find_api_key, only: [:update, :destroy]

  def create
    @api_key = @catalog.api_keys.create(api_key_params)
    redirect_to(catalog_admin_api_path, notice: I18n.t("api_keys.create.success"))
  end

  def update
    authorize(@api_key)
    @api_key.update(api_key_params)
    redirect_to(catalog_admin_api_path, notice: I18n.t("api_keys.update.success"))
  end

  def destroy
    authorize(@api_key)
    @api_key.destroy!
    redirect_to(catalog_admin_api_path, notice: I18n.t("api_keys.destroy.success"))
  end

  private

  def find_api_key
    @api_key = @catalog.api_keys.find(params[:id])
  end

  def api_key_params
    params.require(:api_key).permit(
      :label
    )
  end
end
