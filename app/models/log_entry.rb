class LogEntry < ApplicationRecord
  belongs_to :catalog
  belongs_to :subject, polymorphic: true
  belongs_to :author, class_name: User.to_s, optional: true
  belongs_to :related_to, polymorphic: true, optional: true

  scope :ordered, -> { order(created_at: :desc) }

  def self.validity
    ENV["LOG_ENTRIES"].present? ? Integer(ENV["LOG_ENTRIES"]).months : 4.months
  end
end
