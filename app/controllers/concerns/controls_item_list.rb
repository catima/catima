module ControlsItemList
  extend ActiveSupport::Concern

  included do
    helper_method :item_list
  end

  private

  def item_list
    # TODO: references?
    return browse if params[:browse].present?
    return advanced_search if params[:search].present?
    return simple_search if params[:q].present?
  end

  def browse
    browse_data = ItemList::Filter.parse_param(params[:browse])
    field_slug = browse_data[:field_slug]
    return nil if field_slug.nil?

    @search ||= ItemList::Filter.new(
      :item_type => item_type,
      :field => item_type.fields.where(:slug => field_slug).first,
      :value => browse_data[:value]
    )
  end

  def advanced_search
    model = catalog.advanced_searches.where(:uuid => params[:search]).first
    return nil if model.nil?

    @search ||= ItemList::AdvancedSearchResult.new(:model => model)
  end

  def simple_search
    @search ||= ItemList::SimpleSearchResult.new(
      :catalog => catalog,
      :query => params[:q],
      :item_type_slug => params[:item_type_slug],
      :search_uuid => params[:uuid]
    )
  end
end
