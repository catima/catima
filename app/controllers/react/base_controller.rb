class React::BaseController < ApplicationController
  def catalog_request_clearance
    return false unless Catalog.valid?(request[:catalog_slug])

    raise Pundit::NotAuthorizedError unless catalog_request_valid?
  end

  private

  def catalog_request_valid?
    catalog = Catalog.find_by(slug: request[:catalog_slug])
    catalog.public? || current_user
  end
end
