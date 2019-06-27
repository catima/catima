class DocumentationController < ApplicationController
  include ControlsCatalog

  def index
  end

  protected

  def track
    track_event("catalog_front")
  end
end
