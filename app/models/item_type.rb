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
  include HasTranslations
  include HasSlug

  belongs_to :catalog

  has_many :fields, -> { sorted }
  has_many :list_view_fields,
           -> { where(:display_in_list => true).sorted },
           :class_name => "Field"

  has_many :items

  store_translations :name, :name_plural

  validates_presence_of :catalog
  validates_slug :scope => :catalog_id

  def self.sorted(locale=I18n.locale)
    order("LOWER(item_types.name_translations->>'name_#{locale}') ASC")
  end

  def primary_field
    @primary_field ||= fields.to_a.find(&:primary?)
  end

  def sorted_items
    items.sorted_by_field(primary_field)
  end
end
