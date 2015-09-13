class ViewsController < ApplicationController
  
  def show
    @catalog = Instance.find_by(url: params['catalog'])
    @view = View.find_by(slug: params['slug'], instance:@catalog)
  end
  
end
