class CustomWithDashSimpleSearchesController < SimpleSearchesController
  def show
    redirect_to items_url(:catalog_slug => 'one', :locale => 'en', :item_type_slug => 'authors')
  end
end
