# == Schema Information
#
# Table name: item_views
#
#  created_at            :datetime         not null
#  default_for_item_view :boolean
#  default_for_list_view :boolean
#  id                    :integer          not null, primary key
#  item_type_id          :integer
#  name                  :string
#  template              :jsonb
#  updated_at            :datetime         not null
#

class ItemView < ActiveRecord::Base
  belongs_to :item_type

  validates_presence_of :item_type
  validates_presence_of :name
  validates_presence_of :template

  serialize :template, HashSerializer

  after_save :remove_default_list_view_from_other_views, if: :default_for_list_view?
  after_save :remove_default_item_view_from_other_views, if: :default_for_item_view?

  def remove_default_item_view_from_other_views
    item_type.item_views.where("item_views.id != ?", id).update_all(:default_for_item_view => false)
  end

  def remove_default_list_view_from_other_views
    item_type.item_views.where("item_views.id != ?", id).update_all(:default_for_list_view => false)
  end

  def props(locale)
    p = JSON.parse(template)
    { content: p[locale] || '', locale: locale }
  end
end
