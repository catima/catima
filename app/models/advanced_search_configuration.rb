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
#  search_type        :string           default("default"), not null
#  slug               :string
#  title_translations :jsonb
#  updated_at         :datetime         not null
#

# Note: This is the ActiveRecord model for storing advanced search configurations created by an admin
#
class AdvancedSearchConfiguration < ApplicationRecord
  TYPES = {
    "Default" => "default",
    "Map" => "map"
  }.freeze

  include HasTranslations
  include HasLocales

  delegate :item_types, :to => :catalog

  belongs_to :catalog
  belongs_to :creator, :class_name => "User", optional: true
  belongs_to :item_type, -> { active }

  store_translations :title

  validates_presence_of :catalog
  validates_presence_of :item_type
  validates_presence_of :title

  serialize :description, HashSerializer
  locales :description

  def field_set
    field_set = []
    fields.sort_by {|_field_uuid, position| position}.each do |field_uuid|
      field_set << Field.find_by(:uuid => field_uuid)
    end

    field_set
  end

  def sorted_fields
    fields.sort_by { |_key, order| order }.to_h
  end

  def available_fields
    item_type.fields.select(&:human_readable?).reject do |field|
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

  def include_geographic_field?
    return false if item_type.nil?

    item_type.fields.each do |field|
      return true if field.type == Field::TYPES["geometry"]
    end

    false
  end

  def search_type_map?
    search_type == AdvancedSearchConfiguration::TYPES['Map']
  end
end
