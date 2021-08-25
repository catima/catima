# Mixin intented for ItemsController. Requires a `item_type` method.
module ControlsItemSorting
  extend ActiveSupport::Concern

  included do
    helper_method :current_sort_field, :sort_field_choices, :param_for_sort
  end

  private

  def apply_sort(items, all_human_readable: false, direction: 'ASC')
    field = current_sort_field(all_human_readable: all_human_readable)
    field ? items.sorted_by_field(field, direction: direction) : items
  end

  def current_sort_field(all_human_readable: false)
    current_slug = params[:sort] || item_type.primary_field.try(:slug)
    default = -> { sort_field_choices(all_human_readable: all_human_readable).first }
    sort_field_choices(all_human_readable: all_human_readable).find(default) { |field| field.slug == current_slug }
  end

  def sort_field_choices(all_human_readable: false)
    if all_human_readable
      item_type.fields.select(&:human_readable?)
    else
      item_type.sortable_list_view_fields
    end.reject(&:multiple)
  end

  def param_for_sort(field)
    { :sort => field.slug }
  end
end
