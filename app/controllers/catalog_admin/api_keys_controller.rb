class CatalogAdmin::APIKeysController < CatalogAdmin::BaseController
  before_action :find_catalog

  def create
    authorize(@catalog)
    @api_key = @catalog.api_keys.create(api_key_params)
    redirect_to(catalog_admin_settings_path, notice: I18n.t("searches.edit.success"))
  end

  def update
    authorize(@catalog)
    @api_key = @catalog.api_keys.find(params[:id])
    @api_key.update(api_key_params)
    redirect_to(catalog_admin_settings_path, notice: I18n.t("searches.edit.success"))
  end

  def destroy
    authorize(@catalog)
    @api_key = @catalog.api_keys.find(params[:id])
    @api_key.revoke
    redirect_to(catalog_admin_settings_path, notice: I18n.t("searches.edit.success"))
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
