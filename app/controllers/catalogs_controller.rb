class CatalogsController < ApplicationController

  def show
    @url = params[:catalog]
    @catalog = Instance.find_by(url:@url)
    raise ActionController::RoutingError.new('Not Found') if @catalog.nil?
  end

end
