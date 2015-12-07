class CatalogAdmin::Categories::FieldsController < CatalogAdmin::FieldsController
  private

  # Override superclass
  def find_field_set
    @field_set = catalog.categories.find(params[:category_id])
  end
end
