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
#  title        :jsonb
#  title_old    :string
#  updated_at   :datetime         not null
#  url          :jsonb
#  url_old      :text
#

class MenuItem < ApplicationRecord
  include HasLocales
  include Clone

  belongs_to :catalog
  belongs_to :item_type, optional: true
  belongs_to :page, optional: true

  has_many :children, class_name: 'MenuItem', foreign_key: 'parent_id', :dependent => :destroy
  belongs_to :parent, class_name: 'MenuItem', optional: true

  validates_presence_of :catalog
  validates_presence_of :title

  serialize :title, HashSerializer
  serialize :url, HashSerializer
  locales :title, :url

  include Rails.application.routes.url_helpers

  def self.sorted
    order("menu_items.rank ASC")
  end

  def submenus
    return nil if parent_id # we don't have nested menus

    MenuItem.where(parent_id: id).order("menu_items.rank ASC")
  end

  def get_url
    if not item_type.nil?
      items_path(catalog, I18n.locale, item_type.slug)
    elsif not page.nil?
      page_path(catalog, I18n.locale, page)
    elsif not url.empty?
      url
    else
      '#'
    end
  end

  def describe
    as_json(only: %i(slug rank)) \
      .merge("parent": parent_id.nil? ? nil : MenuItem.find(parent_id).slug,
             "page": page.nil? ? nil : page.slug,
             "item-type": item_type.nil? ? nil : item_type.slug,
             "title": title_json,
             "url": url_json
            )
  end

  def update_from_json(d)
    d['item_type'] = catalog.item_types.find_by(slug: d['item-type']) unless d['item-type'].nil?
    d['page'] = catalog.pages.find_by(slug: d['page']) unless d['page'].nil?
    d['parent_id'] = catalog.pages.find_by(slug: d['parent'])&.id unless d['parent'].nil?
    update(d.except('item-type', 'parent'))
  end
end
