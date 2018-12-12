class API::V2::FieldsController < ActionController::Base
  include ControlsItemSorting

  InvalidItemType = Class.new(RuntimeError)
  InvalidField = Class.new(RuntimeError)

  rescue_from InvalidItemType, InvalidField do |exception|
    status = 400
    error = {
      :status => status,
      :error => "Bad request",
      :message => exception.message
    }
    render(:json => error, :status => status)
  end

  def index
    it = item_type
    category = find_category
    field = find_field(it, category)

    render(json:
      {
        slug: it&.slug,
        name: it&.name,
        search_placeholder: t("catalog_admin.items.reference_editor.reference_editor_search", locale: params[:locale]),
        filter_placeholder: t("catalog_admin.items.reference_editor.reference_editor_filter", locale: params[:locale]),
        selectCondition: field.search_conditions_as_hash,
        inputType: field.type,
        inputData: field.search_data_as_hash,
        inputOptions: field.search_options_as_hash
      })
  end

  private

  def item_type
    return nil if params[:item_type_slug].blank?

    item_type = catalog.item_types.where(:slug => params[:item_type_slug]).first
    raise InvalidItemType, "item_type not found: #{params[:item_type_slug]}" if item_type.nil?

    item_type
  end

  def find_category
    return nil if params[:category_id].blank?

    category = catalog.categories.where(:id => params[:category_id]).first
    raise InvalidItemType, "category not found: #{params[:category_id]}" if category.nil?

    category
  end

  def find_field(item_type, category)
    return nil if params[:field_slug].blank?

    if category.blank?
      field = item_type.fields.find_by(:slug => params[:field_slug])
      # In case we search for a category field in a reference
      field = item_type.all_fields.select { |fld| fld.slug == params[:field_slug] }.first if field.nil?
    else
      field = category.fields.find_by(:slug => params[:field_slug])
    end

    raise InvalidField, "field not found: #{params[:field_slug]}" if field.nil?

    field
  end

  def catalog
    @catalog ||= Catalog.active.find_by!(:slug => params[:catalog_slug])
  end
end
