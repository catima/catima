# Remembering the location of the user
module FriendlyForwarding
  extend ActiveSupport::Concern

  def redirect_back_or(default, options={})
    location = session.delete(:forwarding_url) || default
    redirect_to location, options
  end

  def store_location
    session[:forwarding_url] = request.url if request.get?
  end
end
