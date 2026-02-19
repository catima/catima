# == Schema Information
#
# Table name: advanced_search_configurations
#
#  id                 :bigint           not null, primary key
#  description        :jsonb
#  fields             :jsonb
#  options            :jsonb
#  search_type        :string           default("default")
#  slug               :string
#  title_translations :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  catalog_id         :bigint
#  creator_id         :integer
#  item_type_id       :bigint
#
# Indexes
#
#  index_advanced_search_configurations_on_catalog_id    (catalog_id)
#  index_advanced_search_configurations_on_item_type_id  (item_type_id)
#  index_advanced_search_configurations_on_slug          (slug)
#
# Foreign Keys
#
#  fk_rails_...  (catalog_id => catalogs.id)
#  fk_rails_...  (item_type_id => item_types.id)
#

# NOTE: This is the ActiveRecord model for storing advanced search configurations created by an admin
#
class AdvancedSearchConfiguration < ApplicationRecord
  TYPES = {
    "Default" => "default",
    "Map" => "map"
  }.freeze

  store_accessor :options, :layers, :geofields

  include HasTranslations
  include HasLocales

  delegate :item_types, :to => :catalog

  belongs_to :catalog
  belongs_to(
    :creator,
    -> { unscope(where: :deleted_at) },
    inverse_of: :advanced_search_configurations,
    :class_name => "User",
    optional: true
  )
  belongs_to :item_type, -> { not_deleted }, :inverse_of => false

  has_many :advanced_searches, dependent: :nullify

  store_translations :title

  validates_presence_of :catalog
  validates_presence_of :item_type
  validate :geofields_validation

  scope :with_active_item_type, -> { joins(:item_type).where(item_types: { deleted_at: nil }) }

  serialize :description, coder: HashSerializer
  locales :description

  def custom_container_permitted_attributes
    %i(layers geofields)
  end

  def field_set
    field_set = []
    sorted_fields.each_key do |field_uuid|
      field = Field.find_by(:uuid => field_uuid)
      if field.nil?
        # If the field is not available anymore,
        # delete it from the saved fields
        fields.delete(field_uuid)
        save
      else
        field_set << field
      end
    end

    field_set
  end

  # Return field uuids sorted by position
  def sorted_fields
    fields.sort_by { |_key, order| order }.to_h
  end

  def available_fields
    # Select all human readable or filterable fields, then reject all fields
    # already included in the advanced search configuration
    item_type.fields.select { |f| f.human_readable? || f.filterable? }.reject do |field|
      field_set.include?(field)
    end
  end

  def remove_field(field)
    gap_position = fields[field]
    fields.delete(field)
    self.fields = fields.transform_values do |position|
      if position > gap_position
        position - 1
      else
        position
      end
    end
  end

  def move_field_up(field)
    original_position = fields[field]

    self.fields = fields.transform_values do |position|
      case position
      when original_position - 1
        position + 1
      when original_position
        position - 1
      else
        position
      end
    end
  end

  def move_field_down(field)
    original_position = fields[field]

    self.fields = fields.transform_values do |position|
      case position
      when original_position + 1
        position - 1
      when original_position
        position + 1
      else
        position
      end
    end
  end

  def search_type_map?
    search_type == AdvancedSearchConfiguration::TYPES['Map']
  end

  def geo_layers
    layers.present? ? JSON.parse(layers) : []
  end

  def geo_fields
    geofields.present? ? JSON.parse(geofields) : []
  end

  def geo_fields_as_fields
    item_type
      .fields
      .where(:type => 'Field::Geometry')
      .filter { |f| geo_fields.include?(f.id) }
  end

  private

  def geofields_validation
    return if geo_fields.empty?

    valid_geofield_ids = item_type.fields.where(:type => 'Field::Geometry').pluck(:id)

    invalid_fields = geo_fields - valid_geofield_ids

    errors.add :geofields, I18n.t('catalog_admin.containers.geofields_invalid') if invalid_fields.any?
  end
end
