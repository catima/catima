# == Schema Information
#
# Table name: menu_items
#
#  catalog_id   :integer
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  item_type_id :integer
#  locale       :string           default("fr")
#  page_id      :integer
#  parent_id    :integer
#  rank         :integer
#  slug         :string
#  title        :string
#  updated_at   :datetime         not null
#  url          :text
#

class MenuItem < ActiveRecord::Base
  before_save :ensure_locale

  belongs_to :catalog
  belongs_to :item_type
  belongs_to :page

  validates_presence_of :catalog
  validates_presence_of :title
  validates_presence_of :locale

  include Rails.application.routes.url_helpers


  def self.sorted
    order("menu_items.rank ASC")
  end

  def submenus
    return nil if parent_id   # we don't have nested menus
    MenuItem.where(parent_id: id).where(locale: locale).order("menu_items.rank ASC")
  end

  def get_url
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

  private

  def ensure_locale
    # make sure the locale is one of the available catalog locals
    # if not, set it to the main locale of the catalog
    locale = catalog.primary_language unless locale.in?(catalog.valid_locales)
  end
end
