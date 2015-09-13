class CatalogsController < ApplicationController

  def show
    @url = params[:catalog]
    @catalog = Instance.find_by(url:@url)
    raise ActionController::RoutingError.new('Not Found') if @catalog.nil?
    # TODO it would be good to have a mechanism to redirect from old urls
    # TODO we need to double check on project names that are not allowed (admin, etc.). Probably in the model validation.
  end
  
  
  def admin
    @url = params[:catalog]
    @catalog = Instance.find_by(url:@url)
  end
  
  
  def element_admin
    @url = params[:catalog]
    @catalog = Instance.find_by(url:@url)
    @element = @catalog.schema_elements.where(name:params[:element]).first
    @items = []
    @element.items.each do |i|
      idata = JSON.parse(i.data)
      idata['id'] = i.id
      @items.push(idata)
    end
  end
  
  
  def element_edit
    @catalog = Instance.find_by(url:params[:catalog])
    @element = @catalog.schema_elements.where(name:params[:element]).first
    i = Item.where(id:params[:id], schema_element_id:@element.id).first
    @item = JSON.parse(i.data)
    @item['id'] = i.id
  end

end
