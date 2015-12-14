# == Schema Information
#
# Table name: item_types
#
#  catalog_id               :integer
#  created_at               :datetime         not null
#  deactivated_at           :datetime
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
  include HasDeactivation
  include HasFields
  include HasTranslations
  include HasSlug

  has_many :items
  store_translations :name, :name_plural
  validates_slug :scope => [:catalog_id, :deactivated_at]

  def self.sorted(locale=I18n.locale)
    order("LOWER(item_types.name_translations->>'name_#{locale}') ASC")
  end

  # An array of all fields in this item type, plus any nested fields included
  # by way of categories. Note that this only descends one level: it does not
  # recurse.
  def all_fields
    fields.each_with_object([]) do |field, all|
      all << field
      next unless field.is_a?(Field::ChoiceSet)
      field.choices.each do |choice|
        category = choice.category
        all.concat(category.fields) if category && category.active?
      end
    end
  end

  # Same as all_fields, but limited to display_in_list=>true.
  def all_list_view_fields
    all_fields.select(&:display_in_list)
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
