class API::V2::ItemsController < ActionController::Base
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
    it = item_type
    raise InvalidItemType, 'no item type provided' if it.nil?
    render(json: {
      slug: it.slug,
      name: it.name,
      fields: it.fields.map do |fld|
        {
          slug: fld.slug,
          name: fld.name,
          type: fld.type,
          multiple: fld.multiple,
          primary: fld.primary,
          display_in_list: fld.display_in_list
        }
      end,
      items: it.items.map { |itm| itm.describe([:default_display_name], [:requires_review, :uuid]) }
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
    @catalog ||= Catalog.active.find_by!(:slug => params[:catalog_slug])
  end
end
