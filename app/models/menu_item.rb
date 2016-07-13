# == Schema Information
#
# Table name: menu_items
#
#  catalog_id   :integer
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  item_type_id :integer
#  page_id      :integer
#  parent_id    :integer
#  rank         :integer
#  slug         :string
#  title        :string
#  updated_at   :datetime         not null
#  url          :text
#

class MenuItem < ActiveRecord::Base
  belongs_to :catalog
  belongs_to :item_type
  belongs_to :page

  validates_presence_of :catalog
  validates_presence_of :title

  include Rails.application.routes.url_helpers


  def self.sorted
    order("menu_items.rank ASC")
  end

  def submenus
    return nil if parent_id   # we don't have nested menus
    MenuItem.where(parent_id: id).order("menu_items.rank ASC")
  end

  def get_url(locale=nil)
    locale = catalog.primary_language if locale.nil?
    if not item_type.nil?
      items_path(catalog, locale, item_type.slug)
    elsif not page.nil?
      page_path(catalog, locale, page)
    elsif not url.empty?
      url
    else
      '#'
    end
  end
end
