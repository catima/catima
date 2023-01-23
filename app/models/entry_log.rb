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
