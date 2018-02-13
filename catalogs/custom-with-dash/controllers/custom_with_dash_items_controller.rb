class CustomWithDashItemsController < ItemsController
  def index
    redirect_to send(
      'items_one_url',
      :locale => 'en', :item_type_slug => 'authors'
    )
  end
end
