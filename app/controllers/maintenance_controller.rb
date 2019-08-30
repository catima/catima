class MaintenanceController < ApplicationController
  skip_before_action :handle_maintenance
  before_action :redirect_when_disabled

  def show
    render :show, status: :service_unavailable
  end

  private

  def redirect_when_disabled
    redirect_back_or root_path if maintenance_mode_disabled? || remote_address_whitelisted?
  end
end
