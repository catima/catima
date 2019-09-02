# Dynamic Maintenance Mode
module MaintenanceMode
  extend ActiveSupport::Concern

  included do
    before_action :handle_maintenance
  end

  private

  def handle_maintenance
    return unless maintenance_mode_enabled?
    return if remote_address_whitelisted?

    store_location
    redirect_to maintenance_path
  end

  def maintenance_mode_enabled?
    ENV["MAINTENANCE_MODE"].present? ? to_boolean(ENV["MAINTENANCE_MODE"]) : true
  end

  def maintenance_mode_disabled?
    !maintenance_mode_enabled?
  end

  def remote_address_whitelisted?
    maintainer_ips.split(',').include?(request.remote_ip)
  end

  def maintainer_ips
    ENV['MAINTAINER_IPS'] || ''
  end

  def to_boolean(string)
    ActiveRecord::Type::Boolean.new.cast(string)
  end
end
