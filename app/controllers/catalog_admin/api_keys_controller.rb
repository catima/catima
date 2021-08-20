class CatalogAdmin::APIKeysController < CatalogAdmin::BaseController
  before_action :find_catalog

  def create
    authorize(@catalog)
    @api_key = @catalog.api_keys.create(api_key_params)
    redirect_to(catalog_admin_api_path, notice: I18n.t("api_keys.create.success"))
  end

  def update
    authorize(@catalog)
    @api_key = @catalog.api_keys.find(params[:id])
    @api_key.update(api_key_params)
    redirect_to(catalog_admin_api_path, notice: I18n.t("api_keys.update.success"))
  end

  def destroy
    authorize(@catalog, :revoke_api_key?)
    @api_key = @catalog.api_keys.find(params[:id])
    @api_key.revoke
    redirect_to(catalog_admin_api_path, notice: I18n.t("api_keys.destroy.success"))
  end

  private

  def api_key_params
    params.require(:api_key).permit(
      :label
    )
  end

  def find_catalog
    @catalog = Catalog.find_by(slug: params[:catalog_slug])
  end
end
