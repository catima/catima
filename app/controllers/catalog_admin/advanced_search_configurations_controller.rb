class CatalogAdmin::AdvancedSearchConfigurationsController < CatalogAdmin::BaseController
  layout "catalog_admin/setup/form"

  def index
    authorize(AdvancedSearchConfiguration)
    render("index", :layout => "catalog_admin/setup")
  end

  def new
    build_advanced_search_configuration
    authorize(@advanced_search_conf)
  end

  def create
    build_advanced_search_configuration
    authorize(@advanced_search_conf)
    if @advanced_search_conf.update(advanced_search_conf_params.except(:item_type))
      flash[:notice] = advanced_search_configuration_updated_message
      redirect_to(edit_catalog_admin_advanced_search_configuration_path(
        :catalog_slug => @advanced_search_conf. catalog,
        :id => @advanced_search_conf.id)
      )
    else
      render("new")
    end
  end

  def edit
    find_advanced_search_configuration
    @available_fields = @advanced_search_conf.available_fields
    authorize(@advanced_search_conf)
  end

  def update
    find_advanced_search_configuration
    authorize(@advanced_search_conf)

    add_field_to_advanced_search_configuration
    if advanced_search_conf_params[:field_position].present?
      @advanced_search_conf.move_field_up(advanced_search_conf_params[:field]) if advanced_search_conf_params[:field_position] == "up"
      @advanced_search_conf.move_field_down(advanced_search_conf_params[:field]) if advanced_search_conf_params[:field_position] == "down"
    end

    if @advanced_search_conf.update(advanced_search_conf_params.except(:item_type, :field, :field_position))
      @locales = @advanced_search_conf.catalog.valid_locales
      respond_to do |f|
        f.js
        f.html do
          flash[:notice] = advanced_search_configuration_updated_message
          redirect_back(fallback_location: catalog_admin_advanced_search_configurations_path)
        end
      end
    else
      render("edit")
    end
  end

  def destroy
    find_advanced_search_configuration
    authorize(@advanced_search_conf)
    if params[:field].blank?
      @advanced_search_conf.destroy
    else
      @advanced_search_conf.remove_field(params[:field])
      @advanced_search_conf.save
      return redirect_back(fallback_location: catalog_admin_advanced_search_configurations_path)
    end
    redirect_to(catalog_admin_advanced_search_configurations_path, :notice => destroyed_message)
  end

  private

  def build_advanced_search_configuration
    slug = advanced_search_conf_params[:item_type] if params[:advanced_search_configuration].present?
    item_type = catalog.item_types
                       .where(:slug => slug)
                       .first

    @advanced_search_conf = catalog.advanced_search_configurations.new do |model|
      model.creator = current_user
      model.item_type = item_type
    end
  end

  def find_advanced_search_configuration
    @advanced_search_conf = AdvancedSearchConfiguration.find(params[:id])
  end

  def add_field_to_advanced_search_configuration
    return if params[:advanced_search_configuration].blank? || advanced_search_conf_params[:field].blank?

    return if @advanced_search_conf.fields.include?(advanced_search_conf_params[:field])

    @advanced_search_conf.fields[advanced_search_conf_params[:field]] = @advanced_search_conf.fields.count
  end

  def advanced_search_conf_params
    permitted_params = []
    catalog.valid_locales.each do |locale|
      permitted_params << "title_#{locale}".to_sym
    end

    params.require(:advanced_search_configuration).permit(
      :title,
      :description,
      :search_type,
      :item_type,
      :field,
      :field_position,
      permitted_params)
  end

  def advanced_search_configuration_updated_message
    "#{@advanced_search_conf.title} has been saved."
  end

  def destroyed_message
    "Configuration “#{@advanced_search_conf.title}” has been deleted."
  end
end
