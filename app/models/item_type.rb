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

require_dependency 'field/choice_set'

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

  # Same as all_list_view_fields, but limited human_readable?.
  def sortable_list_view_fields
    all_list_view_fields.select(&:human_readable?)
  end

  def primary_field
    @primary_field ||= fields.to_a.find(&:primary?)
  end

  # Field most appropriate for describing this item in a select (i.e. drop-down)
  # menu. This is usually the primary_field, but may be something different if
  # the primary field is not human_readable?.
  def field_for_select
    candidate_fields = [primary_field, list_view_fields, fields].flatten.compact
    candidate_fields.find(&:human_readable?)
  end

  # The primary or first text field. Used to generate Item slugs.
  def primary_text_field
    candidate_fields = [primary_field, list_view_fields, fields].flatten.compact
    candidate_fields.find { |f| f.is_a?(Field::Text) }
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

  # Finds a field based on the slug or UUID
  def find_field(field_id)
    fields.find_by(field_id.starts_with?('_') ? :uuid : :slug => field_id)
  end
end
