# == Schema Information
#
# Table name: entry_logs
#
#  id             :bigint           not null, primary key
#  action         :string           not null
#  record_changes :jsonb
#  subject_type   :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  author_id      :bigint           not null
#  catalog_id     :bigint           not null
#  subject_id     :bigint           not null
#
# Indexes
#
#  index_entry_logs_on_author_id   (author_id)
#  index_entry_logs_on_catalog_id  (catalog_id)
#  index_entry_logs_on_subject     (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#
class EntryLog < ApplicationRecord
  belongs_to :catalog
  belongs_to :subject, polymorphic: true
  belongs_to(
    :author,
    -> { unscope(where: :deleted_at) },
    class_name: 'User',
    inverse_of: :entry_logs,
    optional: true
  )
  belongs_to :related_to, polymorphic: true, optional: true

  scope :ordered, -> { order(created_at: :desc) }

  def self.validity
    ENV["ENTRY_LOGS_VALIDITY"].present? ? Integer(ENV["ENTRY_LOGS_VALIDITY"]).months : 4.months
  end
end
