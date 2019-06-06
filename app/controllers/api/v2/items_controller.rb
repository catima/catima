class API::V2::ItemsController < API::ApplicationController
  include ControlsItemSorting
  before_action :catalog_request_clearance

  InvalidItemType = Class.new(RuntimeError)

  rescue_from InvalidItemType do |exception|
    status = 400
    error = {
      :status => status,
      :error => "Bad request",
      :message => exception.message
    }
    render(:json => error, :status => status)
  end

  def index
    raise InvalidItemType, 'no item type provided' if item_type.nil?

    fields = params[:simple_fields].blank? ? item_type.fields : item_type.simple_fields

    # Here we add to the current order another order in case some items have exactly the same primary_text_field value
    items = apply_sort(item_type.items).order(:id)
    items = apply_search(items)
    items = apply_except(items)
    items = apply_pagination(items)

    render(json:
      {
        slug: item_type.slug, name: item_type.name,
        select_placeholder: t("catalog_admin.items.reference_editor.reference_editor_select"),
        search_placeholder: t("catalog_admin.items.reference_editor.reference_editor_search"),
        filter_placeholder: t("catalog_admin.items.reference_editor.reference_editor_filter", locale: params[:locale]),
        loading_message: t("loading", locale: params[:locale]),
        fields: fields.map { |fld| field_json_attributes(fld) },
        items: items.map { |itm| itm.describe([:default_display_name], [:requires_review, :uuid], true) },
        hasMore: params[:page].present? && params[:page].to_i < items.total_pages
      })
  end

  private

  def item_type
    return nil if params[:item_type].blank?

    item_type = catalog.item_types.where(:slug => params[:item_type]).first
    raise InvalidItemType, "item_type not found: #{params[:item_type]}" if item_type.nil?

    item_type
  end

  def catalog
    @catalog ||= Catalog.find_by!(:slug => params[:catalog_slug])
  end

  def apply_search(items)
    return items if params[:search].blank?

    items.where("LOWER(search_data_#{I18n.locale}) LIKE ?", "%#{params[:search].downcase}%")
  end

  def apply_except(items)
    return items if params[:except].blank?

    items.where("id NOT IN (#{params[:except].join(', ')})")
  end

  def apply_pagination(items)
    return items if params[:page].blank?

    items.page(params[:page])
  end

  def field_json_attributes(field)
    {
      slug: field.slug,
      name: field.name,
      type: field.type,
      multiple: field.multiple,
      primary: field.primary,
      display_in_list: field.display_in_list,
      human_readable: field.human_readable?,
      filterable: field.filterable?,
      displayable_to_user: field.displayable_to_user?(current_user),
      uuid: field.uuid
    }
  end
end
