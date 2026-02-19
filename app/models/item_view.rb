# == Schema Information
#
# Table name: item_views
#
#  id                       :integer          not null, primary key
#  default_for_display_name :boolean          default(FALSE)
#  default_for_item_view    :boolean
#  default_for_list_view    :boolean
#  name                     :string
#  template                 :jsonb
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  item_type_id             :integer
#
# Indexes
#
#  index_item_views_on_item_type_id  (item_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_type_id => item_types.id)
#

# rubocop:disable Rails/SkipsModelValidations
class ItemView < ApplicationRecord
  belongs_to :item_type

  validates_presence_of :item_type
  validates_presence_of :name

  serialize :template, coder: HashSerializer

  after_save :remove_default_list_view_from_other_views, if: :default_for_list_view?
  after_save :remove_default_item_view_from_other_views, if: :default_for_item_view?

  def remove_default_item_view_from_other_views
    item_type.item_views.where.not(item_views: { id: id }).update_all(:default_for_item_view => false)
  end

  def remove_default_list_view_from_other_views
    item_type.item_views.where.not(item_views: { id: id }).update_all(:default_for_list_view => false)
  end

  def render(item, locale, view_type=:display_name)
    presenter = ItemViewPresenter.new(self, self, item, locale, strip_p: true)
    presenter.render(view_type)
  end

  def template_json
    JSON.parse template
  end

  def describe
    as_json(only: %i(name default_for_display_name default_for_item_view default_for_list_view)).merge(
      item_type: item_type.slug,
      template: template_json
    )
  end
end
