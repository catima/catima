class CustomWithDashCatalogsController < CatalogsController
  def show
    redirect_to catalog_home_url(:catalog_slug => 'one', :locale => 'en')
  end
end
