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
    Rails.root.join('exports').to_s + "/#{id}_#{name}.zip"
  end

  def valid?
    Time.zone.now < created_at.to_date + validity
  end

  def ready?
    status.eql? "ready"
  end

  def validity
    1.week
  end
end
