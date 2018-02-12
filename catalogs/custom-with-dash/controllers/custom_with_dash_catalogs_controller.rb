class CustomWithDashCatalogsController < CatalogsController
  def show
    redirect_to send("catalog_one_url")
  end
end
