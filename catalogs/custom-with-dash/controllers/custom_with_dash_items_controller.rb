class CustomWithDashItemsController < ItemsController
  def index
    redirect_to send(
      'one_items_url',
      :locale => 'en', :item_type_slug => 'authors'
    )
  end
end
