# == Schema Information
#
# Table name: choice_sets
#
#  catalog_id     :integer
#  created_at     :datetime         not null
#  deleted_at :datetime
#  id             :integer          not null, primary key
#  name           :string
#  slug           :string
#  updated_at     :datetime         not null
#  uuid           :string
#

class ChoiceSet < ApplicationRecord
  include HasDeactivation
  include HasDeletion
  include Clone

  enum choice_set_type: { default: 0, datation: 1 }
  FORMATS = %w(Y M h YM MD hm YMD hms MDh YMDh MDhm YMDhm MDhms YMDhms).freeze

  def self.datation
    where(choice_set_type: :datation)
  end

  def self.default
    where(choice_set_type: :default)
  end

  belongs_to :catalog
  has_many :choices, ->(set) { where(:catalog_id => set.catalog_id).order(:position) }, :dependent => :delete_all
  has_many :fields, :dependent => :destroy

  accepts_nested_attributes_for :choices,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  validates_presence_of :catalog
  validates_presence_of :name
  validate :format_present_if_datation

  before_create :assign_uuid

  def self.sorted
    order(Arel.sql("LOWER(choice_sets.name)"))
  end

  def describe
    as_json(only: %i(uuid name deactivated_at)).merge(choices: choices.map(&:describe))
  end

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def choice_prefixed_label(choice, format: :short)
    (parent_choices(choice) + [choice]).map { |d| (format == :long) ? d.long_display_name : d.short_name }.join(" / ")
  end

  def flat_ordered_choices
    @flat_ordered_choices ||= recursive_ordered_choices(choices.ordered.reject(&:parent_id?)).flatten
  end

  def find_sub_choices(parent)
    choices.select { |choice| choice.parent_id == parent.id }
  end

  private

  def parent_choices(choice, choices=[])
    if (parent = find_parent(choice))
      choices += parent_choices(parent, choices)
      choices += [parent]
    end
    choices
  end

  def recursive_ordered_choices(choices, deep: 0)
    choices.flat_map do |choice|
      [choice, recursive_ordered_choices(find_sub_choices(choice), deep: deep + 1)]
    end
  end

  def find_parent(choice)
    choices.detect { |item| item.id == choice.parent_id } if choice.parent_id?
  end

  def format_present_if_datation
    return if choice_set_type != 'datation'
    return unless format.empty?

    errors.add(
      :format,
      I18n.t("errors.messages.blank")
    )
  end
end
