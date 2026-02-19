# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  name       :string
#  uuid       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  catalog_id :integer
#
# Indexes
#
#  index_categories_on_catalog_id           (catalog_id)
#  index_categories_on_uuid_and_catalog_id  (uuid,catalog_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (catalog_id => catalogs.id)
#

class Category < ApplicationRecord
  include HasFields
  include HasHumanId
  include HasDeletion
  include Clone

  human_id :name
  validates_presence_of :name

  before_create :assign_uuid
  before_destroy :unset_category_in_choice_sets

  def self.sorted
    order(Arel.sql("LOWER(categories.name) ASC"))
  end

  def describe
    as_json(only: %i(name uuid)).merge(fields: fields.map(&:describe))
  end

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def unset_category_in_choice_sets
    Choice.where(category_id: id).find_each { |ch| ch.update(category_id: nil) }
  end
end
