# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  text       :text             not null
#  severity   :string           default("info"), not null
#  scope      :string           default("admin"), not null
#  active     :boolean          default(FALSE), not null
#  starts_at  :datetime
#  ends_at    :datetime
#  catalog_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Message < ApplicationRecord
  belongs_to :catalog, optional: true

  validates :text, presence: true
  validates :severity, inclusion: { in: %w[info warning danger] }
  validates :scope, inclusion: { in: %w[admin public all] }
  validate :end_date_after_start_date

  scope :active, lambda {
    where(active: true)
      .where('starts_at IS NULL OR starts_at <= ?', Time.current)
      .where('ends_at IS NULL OR ends_at >= ?', Time.current)
  }

  scope :for_admin, -> { where(scope: %w[admin all]) }
  scope :for_public, -> { where(scope: %w[public all]) }
  scope :for_catalog, ->(catalog) { where('catalog_id IS NULL OR catalog_id = ?', catalog&.id) }

  scope :by_severity_and_date, lambda {
    order(Arel.sql("CASE severity WHEN 'danger' THEN 1 WHEN 'warning' THEN 2 ELSE 3 END, created_at DESC"))
  }

  def active?
    return false unless active

    # Check if within date range
    return false if starts_at.present? && starts_at > Time.current
    return false if ends_at.present? && ends_at < Time.current

    true
  end

  def rendered_text
    markdown_renderer.render(text).html_safe # rubocop:disable Rails/OutputSafety
  end

  private

  def markdown_renderer
    @markdown_renderer ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(filter_html: true, safe_links_only: true),
      autolink: true,
      tables: true,
      no_intra_emphasis: true
    )
  end

  def end_date_after_start_date
    return if ends_at.blank? || starts_at.blank?
    return unless ends_at < starts_at

    errors.add(:ends_at, "must be after start date")
  end
end
