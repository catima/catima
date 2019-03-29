class API::ApplicationController < ApplicationController
  def catalog_request_clearance
    return false unless Catalog.valid?(request[:catalog_slug])

    raise Pundit::NotAuthorizedError unless catalog_request_valid?
  end

  private

  def catalog_request_valid?
    catalog = Catalog.find_by(slug: request[:catalog_slug])
    # Available only for public catalogs or internal requests with valid CSRF tokens
    catalog.public? || valid_authenticity_token?(session, request.env["HTTP_X_CSRF_TOKEN"])
  end
end
