# == Schema Information
#
# Table name: exports
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  catalog_id :integer
#  category   :string
#  status     :string
#  file       :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Export < ActiveRecord::Base
  CATEGORY_OPTIONS = %w(catima).freeze
  STATUS_OPTIONS = %w(error processing ready).freeze

  belongs_to :user
  belongs_to :catalog

  validates_presence_of :user_id
  validates_presence_of :catalog_id

  validates_inclusion_of :category, :in => CATEGORY_OPTIONS
  validates_inclusion_of :status, :in => STATUS_OPTIONS

  after_create do
    ExportWorker.perform_async(id, category)
  end

  def pathname
    Rails.root.join('exports').to_s + "/#{id}_#{catalog.slug}.zip"
  end

  def validity?
    Time.zone.now < created_at.to_date + Export.validity
  end

  def ready?
    status.eql? "ready"
  end

  def file?
    file
  end

  def self.validity
    1.week
  end
end
