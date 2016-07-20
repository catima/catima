class CatalogAdmin::ContainersController < CatalogAdmin::BaseController
  layout "catalog_admin/setup"
  
  def edit
    find_container
    authorize(@container)
  end

  def update
    find_container
    authorize(@container)
    if @container.update(container_params)
      respond_to do |f|
        f.js
        f.html do
          redirect_to(
            edit_catalog_admin_page_path(@container.page.catalog, @container.page),
            :notice => updated_message
          )
        end
      end
    else
      render('edit')
    end
  end

  private

  def container_class
    Container::TYPES.fetch(params[:type], "Container::HTML").constantize
  end

  def find_container
    @container = nil
    c = Container.find(params[:id])
    @container = c if catalog.id == c.page.catalog.id
  end

  def container_params
    params.require(:container).permit(
      :slug,
      :row_order_position,
      *@container.custom_container_permitted_attributes
    )
  end

  def created_message
    "The “#{@container.slug}” container has been created."
  end

  def updated_message
    "The “#{@container.slug}” container has been saved."
  end

  def destroyed_message
    "The “#{@container.slug}” container has been deleted."
  end

end
