class DocumentationController < ApplicationController
  include ControlsCatalog

  def index
  end

  protected

  def track_action
    ahoy.track catalog.slug, request.path_parameters.merge(:scope => "catalog_front")
  end
end
