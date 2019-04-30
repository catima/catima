# == Schema Information
#
# Table name: choice_sets
#
#  catalog_id     :integer
#  created_at     :datetime         not null
#  deactivated_at :datetime
#  id             :integer          not null, primary key
#  name           :string
#  slug           :string
#  updated_at     :datetime         not null
#  uuid           :string
#

class ChoiceSet < ApplicationRecord
  include HasDeactivation

  belongs_to :catalog
  has_many :choices, (lambda do |set|
    where(:catalog_id => set.catalog_id).order(:row_order)
  end), :dependent => :destroy
  has_many :fields, :dependent => :destroy

  accepts_nested_attributes_for :choices,
  :reject_if => :all_blank,
  :allow_destroy => true

  validates_presence_of :catalog
  validates_presence_of :name

  before_create :assign_uuid

  def self.sorted
    order(Arel.sql("LOWER(choice_sets.name)"))
  end

  def describe
    as_json(only: %i(uuid name)).merge("choices": choices.select { |c| c.parent.nil? }.map(&:describe))
  end

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def search_data_as_hash
    choices_as_options = []

    choices.select { |c| c.parent.blank? }.each do |choice|
      option = { :value => choice.short_name, :key => choice.id }
      option[:category_data] = choice.filterable_category_fields

      option[:children] = []
      choice.children.each do |child|
        option[:children] << child.children_as_options
      end

      choices_as_options << option
    end

    choices_as_options
  end

  def synonyms
    synonyms = []

    choices.reject { |c| c.synonyms.blank? }.each do |choice|
      choice.synonyms.each do |synonym|
        synonyms << {
          :choice_option => {
            :value => choice.id,
            :label => choice.short_name,
            :key => choice.id
          },
          :synonym => synonym
        }
      end
    end

    synonyms
  end
end
