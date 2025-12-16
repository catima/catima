require_relative 'daily_item'

class ObjetslittPagesController < PagesController
  include DailyItem

  def show
    @slug = params[:slug]
    @page = catalog.pages.where(:slug => @slug).first!
    @daily_item_data = fetch_daily_item_data

    render :show
  end
end
