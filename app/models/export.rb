# == Schema Information
#
# Table name: exports
#
#  id             :integer          not null, primary key
#  category       :string
#  status         :string
#  use_slugs      :boolean          default(FALSE), not null
#  with_files     :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  catalog_id     :integer
#  user_id        :integer
#  with_catima_id :boolean          default(FALSE), not null
#
# Indexes
#
#  index_exports_on_catalog_id  (catalog_id)
#  index_exports_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (catalog_id => catalogs.id)
#  fk_rails_...  (user_id => users.id)
#

class Export < ApplicationRecord
  CATEGORY_OPTIONS = %w(catima sql csv).freeze
  STATUS_OPTIONS = %w(error processing ready).freeze

  belongs_to(
    :user,
    -> { unscope(where: :deleted_at) },
    :inverse_of => :exports
  )
  belongs_to :catalog

  validates_presence_of :user
  validates_presence_of :catalog

  validates_inclusion_of :category, :in => CATEGORY_OPTIONS
  validates_inclusion_of :status, :in => STATUS_OPTIONS

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
    ENV["EXPORTS_VALIDITY"].present? ? Integer(ENV["EXPORTS_VALIDITY"]).days : 7.days
  end

  def export_catalog(locale)
    ExportWorker.perform_async(
      id,
      locale
    )
  end
end
