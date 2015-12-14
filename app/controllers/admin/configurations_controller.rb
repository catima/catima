class Admin::ConfigurationsController < Admin::BaseController
  def update
    @configuration = ::Configuration.find(params[:id])
    authorize(@configuration)

    if @configuration.update(configuration_params)
      redirect_to(admin_dashboard_path, :notice => "Settings saved")
    else
      # Validation should never fail, so this will not be reached
      # unless something catastrophic happens.
      redirect_to(admin_dashboard_path, :alert => "An error prevented saving")
    end
  end

  private

  def configuration_params
    params.require(:configuration).permit(:root_mode, :default_catalog_id)
  end
end
