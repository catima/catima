class API::ApplicationController < ApplicationController
  # Set curent request context before any action to ensure URL helpers
  # in serializers have access to proper request information for URL generation
  before_action :set_current_request

  def catalog_request_clearance
    return false unless Catalog.valid?(params[:catalog_slug])

    raise Pundit::NotAuthorizedError unless catalog_request_valid?
  end

  private

  def set_current_request
    Current.request = request
  end

  def catalog_request_valid?
    catalog = Catalog.find_by(slug: params[:catalog_slug])
    # Available only for public catalogs or internal requests with valid CSRF tokens
    catalog.public? || valid_authenticity_token?(session, request.env["HTTP_X_CSRF_TOKEN"])
  end
end
