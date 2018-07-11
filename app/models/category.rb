# == Schema Information
#
# Table name: categories
#
#  catalog_id     :integer
#  created_at     :datetime         not null
#  deactivated_at :datetime
#  id             :integer          not null, primary key
#  name           :string
#  updated_at     :datetime         not null
#  uuid           :string
#

class Category < ApplicationRecord
  include HasDeactivation
  include HasFields
  include HasHumanId

  human_id :name
  validates_presence_of :name

  before_create :assign_uuid
  before_destroy :unset_category_in_choice_sets

  def self.sorted
    order("LOWER(categories.name) ASC")
  end

  def describe
    as_json(only: %i(name uuid)).merge("fields": fields.map(&:describe))
  end

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def unset_category_in_choice_sets
    Choice.where(category_id: id).find_each { |ch| ch.update(category_id: nil) }
  end
end
