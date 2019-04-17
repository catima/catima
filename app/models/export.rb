# == Schema Information
#
# Table name: exports
#
#  catalog_id :integer
#  category   :string
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  status     :string
#  updated_at :datetime         not null
#  user_id    :integer
#

class Export < ApplicationRecord
  CATEGORY_OPTIONS = %w(catima sql csv).freeze
  STATUS_OPTIONS = %w(error processing ready).freeze

  belongs_to :user
  belongs_to :catalog

  validates_presence_of :user
  validates_presence_of :catalog

  validates_inclusion_of :category, :in => CATEGORY_OPTIONS
  validates_inclusion_of :status, :in => STATUS_OPTIONS

  after_commit :export_catalog, on: :create

  def pathname
    ext = Rails.env.test? ? "test" : "zip"
    Rails.root.join('exports').to_s + "/#{id}_#{catalog.slug}.#{ext}"
  end

  def validity?
    Time.zone.now < created_at.to_date + Export.validity
  end

  def ready?
    status.eql? "ready"
  end

  def file?
    File.exist? pathname
  end

  def self.validity
    1.week
  end

  def export_catalog
    ExportWorker.perform_async(id, category)
  end
end
