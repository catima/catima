class ItemList::FilterPresenter < ItemListPresenter
  delegate :items_path, :to => :view

  private

  def path
    items_path(
      :item_type_slug => list.item_type,
      list.field.slug => list.value,
      :page => list.page_for_offset(nav.offset_actual)
    ) if list.field
  end

  def context_param
    :browse
  end

  def context_params
    params = super
    # Preserve sort parameters for navigation
    params[:sort_type] = list.sort_type if list.sort_type.present?
    params[:sort_field_id] = list.sort_field.id if list.sort_field.present? && list.sort_field.respond_to?(:id)
    params[:sort] = list.sort if list.sort != 'ASC' # Only include if not default
    params
  end
end
