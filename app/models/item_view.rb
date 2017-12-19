# == Schema Information
#
# Table name: item_views
#
#  created_at               :datetime         not null
#  default_for_display_name :boolean          default(FALSE)
#  default_for_item_view    :boolean
#  default_for_list_view    :boolean
#  id                       :integer          not null, primary key
#  item_type_id             :integer
#  name                     :string
#  template                 :jsonb
#  updated_at               :datetime         not null
#

# rubocop:disable Rails/SkipsModelValidations
# rubocop:disable Rails/OutputSafety
class ItemView < ActiveRecord::Base
  belongs_to :item_type

  validates_presence_of :item_type
  validates_presence_of :name

  serialize :template, HashSerializer

  after_save :remove_default_list_view_from_other_views, if: :default_for_list_view?
  after_save :remove_default_item_view_from_other_views, if: :default_for_item_view?

  def remove_default_item_view_from_other_views
    item_type.item_views.where("item_views.id != ?", id).update_all(:default_for_item_view => false)
  end

  def remove_default_list_view_from_other_views
    item_type.item_views.where("item_views.id != ?", id).update_all(:default_for_list_view => false)
  end

  def render(item, locale)
    tpl = JSON.parse(template)
    local_tpl = tpl[locale.to_s] || ''
    item.fields.each do |field|
      local_tpl = local_tpl.sub('{{' + field.slug + '}}', item.display_value(field, locale))
    end
    local_tpl.html_safe
  end

  def template_json
    JSON.parse template
  end

  def describe
    as_json(only: %i(name default_for_display_name default_for_item_view default_for_list_view)).merge(
      "item_type": item_type.slug,
      "template": template_json
    )
  end
end
