# == Schema Information
#
# Table name: exports
#
#  id         :integer          not null, primary key
#  catalog_id :integer
#  user_id    :integer
#  category   :string
#  name       :string
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Export < ActiveRecord::Base
  CATEGORIES = {
    "catima" => 'Export::Catima'
  }.freeze

  STATUS_OPTIONS = %w(error expired processing ready).freeze

  belongs_to :user
  belongs_to :catalog

  validates_presence_of :user_id
  validates_presence_of :catalog_id

  validates_inclusion_of :status, :in => STATUS_OPTIONS

  after_create do
    ExportWorker.perform_async(id, catalog.slug, category, user.id)
  end

  def status_at_least?(status)
    status_index = STATUS_OPTIONS.index(status.to_s)
    return false if status_index.nil?
    STATUS_OPTIONS.index(status) >= status_index
  end

  def pathname
    Rails.root.join('exports').to_s + "/#{id}_#{name}.zip"
  end
end
