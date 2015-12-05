# == Schema Information
#
# Table name: item_types
#
#  catalog_id               :integer
#  created_at               :datetime         not null
#  id                       :integer          not null, primary key
#  name_old                 :string
#  name_plural_old          :string
#  name_plural_translations :json
#  name_translations        :json
#  slug                     :string
#  updated_at               :datetime         not null
#

# TODO: drop name_old and name_plural_old columns (no longer used)
class ItemType < ActiveRecord::Base
  include HasFields
  include HasTranslations
  include HasSlug

  has_many :items
  store_translations :name, :name_plural
  validates_slug :scope => :catalog_id

  def self.sorted(locale=I18n.locale)
    order("LOWER(item_types.name_translations->>'name_#{locale}') ASC")
  end

  def primary_field
    @primary_field ||= fields.to_a.find(&:primary?)
  end

  def public_items
    items.merge(catalog.public_items)
  end

  def public_sorted_items
    public_items.merge(sorted_items)
  end

  def sorted_items
    items.sorted_by_field(primary_field)
  end
end
