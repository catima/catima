class CatalogAdmin::ItemTypesController < CatalogAdmin::BaseController
  layout "catalog_admin/setup/form"

  def new
    build_item_type
    authorize(@item_type)
  end

  def edit
    find_item_type
    authorize(@item_type)
  end

  def create
    build_item_type
    authorize(@item_type)
    if @item_type.update_and_log(item_type_params, author: current_user, catalog: @catalog)
      redirect_to(after_create_path, :notice => created_message)
    else
      render("new")
    end
  end

  def update
    find_item_type
    authorize(@item_type)
    if @item_type.update_and_log(item_type_params, author: current_user, catalog: @catalog)
      redirect_to(
        catalog_admin_item_type_fields_path(catalog, I18n.locale, @item_type),
        :notice => updated_message
      )
    else
      render("edit")
    end
  end

  def destroy
    find_item_type
    authorize(@item_type)
    # change item type slug to enable user creating a new one with the same slug
    @item_type.update!(:deleted_at => Time.current, :slug => "#{@item_type.slug}-#{SecureRandom.uuid}")
    redirect_to(catalog_admin_setup_path(catalog, I18n.locale), :notice => deleted_message)
  end

  def geofields
    @item_type = catalog.item_types.where(:id => params[:item_types_id]).first!
    authorize(@item_type)
    geofields = @item_type.fields.where(:type => 'Field::Geometry').map do |field|
      {
        :id => field.id,
        :name => field.name
      }
    end
    render json: geofields
  end

  private

  def build_item_type
    @item_type = catalog.item_types.new
  end

  def find_item_type
    @item_type = catalog.item_types.where(:slug => params[:slug]).first!
  end

  def item_type_params
    params.require(:item_type).permit(
      :name_de, :name_plural_de,
      :name_en, :name_plural_en,
      :name_fr, :name_plural_fr,
      :name_it, :name_plural_it,
      :slug,
      :display_emtpy_fields,
      :suggestions_activated,
      :allow_anonymous_suggestions,
      :suggestion_email,
      :seo_indexable
    )
  end

  def after_create_path
    case params[:commit]
    when /another/i then new_catalog_admin_item_type_path
    else catalog_admin_item_type_fields_path(catalog, I18n.locale, @item_type)
    end
  end

  %w(created updated deleted).each do |verb|
    define_method("#{verb}_message") do
      "The “#{@item_type.name}” item type has been #{verb}."
    end
  end
end
