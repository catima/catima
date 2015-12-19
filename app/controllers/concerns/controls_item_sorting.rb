# Mixin intented for ItemsController. Requires a `item_type` method.
module ControlsItemSorting
  extend ActiveSupport::Concern

  included do
    helper_method :current_sort_field, :sort_field_choices, :param_for_sort
  end

  private

  def apply_sort(items)
    field = current_sort_field
    field ? items.sorted_by_field(field) : items
  end

  def current_sort_field
    default = -> { sort_field_choices.first }
    sort_field_choices.find(default) { |field| field.slug == params[:sort] }
  end

  def sort_field_choices
    item_type.sortable_list_view_fields
  end

  def param_for_sort(field)
    { :sort => field.slug }
  end
end
