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
  has_many :choices, ->(set) { where(:catalog_id => set.catalog_id) }, :dependent => :destroy
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
    as_json(only: %i(uuid name)).merge("choices": choices.map(&:describe))
  end

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
