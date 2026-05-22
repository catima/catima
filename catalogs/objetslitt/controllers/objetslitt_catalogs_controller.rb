require_relative 'daily_item'

class ObjetslittCatalogsController < CatalogsController
  include DailyItem

  def show
    @daily_item_data = fetch_daily_item_data
  end
end
