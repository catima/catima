# == Schema Information
#
# Table name: advanced_search_configurations
#
#  catalog_id         :bigint(8)
#  created_at         :datetime         not null
#  creator_id         :integer
#  description        :jsonb
#  fields             :jsonb
#  id                 :bigint(8)        not null, primary key
#  item_type_id       :bigint(8)
#  options            :jsonb
#  search_type        :string           default("default")
#  slug               :string
#  title_translations :jsonb
#  updated_at         :datetime         not null
#

# NOTE: This is the ActiveRecord model for storing advanced search configurations created by an admin
#
class AdvancedSearchConfiguration < ApplicationRecord
  TYPES = {
    "Default" => "default",
    "Map" => "map"
  }.freeze

  store_accessor :options, :layers

  include HasTranslations
  include HasLocales

  delegate :item_types, :to => :catalog

  belongs_to :catalog
  belongs_to(
    :creator,
    -> { unscope(where: :deleted_at) },
    :class_name => "User",
    optional: true
  )
  belongs_to :item_type, -> { not_deleted }, :inverse_of => false

  store_translations :title

  validates_presence_of :catalog
  validates_presence_of :item_type

  scope :with_active_item_type, -> { joins(:item_type).where(item_types: { deleted_at: nil }) }

  serialize :description, HashSerializer
  locales :description

  def custom_container_permitted_attributes
    %i(layers)
  end

  def field_set
    field_set = []
    sorted_fields.each do |field_uuid, _|
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
end
