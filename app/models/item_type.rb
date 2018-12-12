# == Schema Information
#
# Table name: item_types
#
#  catalog_id               :integer
#  created_at               :datetime         not null
#  deactivated_at           :datetime
#  display_emtpy_fields     :boolean          default(TRUE), not null
#  id                       :integer          not null, primary key
#  name_plural_translations :json
#  name_translations        :json
#  slug                     :string
#  updated_at               :datetime         not null
#

require_dependency 'field/choice_set'

class ItemType < ApplicationRecord
  include HasDeactivation
  include HasFields
  include HasTranslations
  include HasSlug

  has_many :items
  has_many :item_views, :dependent => :destroy
  has_many :menu_items, :dependent => :destroy
  store_translations :name, :name_plural
  validates_slug :scope => [:catalog_id, :deactivated_at]

  def self.sorted(locale=I18n.locale)
    order(Arel.sql("LOWER(item_types.name_translations->>'name_#{locale}') ASC"))
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

  # Same as all_fields, but limited to display_in_public_list=>true.
  def all_public_list_view_fields
    all_fields.select(&:display_in_public_list)
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

  # Fields that are not of type Reference or ChoiceSet to prevent n+1 lookup in advanced search
  def simple_fields
    all_public_list_view_fields.reject { |fld| ["Field::Reference", "Field::ChoiceSet"].include?(fld.type) }
  end

  # The primary or first text field. Used to generate Item slugs.
  def primary_text_field
    candidate_fields = [primary_field, list_view_fields, fields].flatten.compact
    candidate_fields.find { |f| f.is_a?(Field::Text) }
  end

  def primary_human_readable_field
    candidate_fields = [primary_field, list_view_fields, fields].flatten.compact
    candidate_fields.find(&:human_readable?)
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

  def default_list_view
    item_views.find_by(default_for_list_view: true)
  end

  def default_item_view
    item_views.find_by(default_for_item_view: true)
  end

  def default_display_name_view
    item_views.find_by(default_for_display_name: true)
  end

  def include_geographic_field?
    fields.each do |field|
      return true if field.type == Field::TYPES["geometry"]
    end

    false
  end
end
