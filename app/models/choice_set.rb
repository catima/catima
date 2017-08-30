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

class ChoiceSet < ActiveRecord::Base
  include HasDeactivation

  belongs_to :catalog
  has_many :choices, ->(set) { where(:catalog_id => set.catalog_id) }

  accepts_nested_attributes_for :choices,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  validates_presence_of :catalog
  validates_presence_of :name

  def self.sorted
    order("LOWER(choice_sets.name)")
  end

  def describe
    as_json(only: %i(uuid name)).merge({"choices": choices.map { |ch| ch.describe }})
  end
end
