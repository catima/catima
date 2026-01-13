# == Schema Information
#
# Table name: ahoy_events
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  properties :jsonb
#  time       :datetime
#  user_id    :bigint(8)
#  visit_id   :bigint(8)
#

class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  belongs_to :visit
  belongs_to(
    :user,
    -> { unscope(where: :deleted_at) },
    inverse_of: :ahoy_events,
    optional: true
  )

  def self.top(limit=5, from=3.months, scope=nil, catalog_slug=nil)
    tops = where("time > ?", from.ago)

    tops = tops.where('properties @> ?', { scope: scope }.to_json) if scope
    tops = tops.where('properties @> ?', { catalog_slug: catalog_slug }.to_json) if catalog_slug

    tops.group(:name)
        .order(Arel.sql('COUNT(*) DESC'))
        .limit(limit)
        .count
        .to_a
  end

  def self.validity
    ENV["AHOY_EVENTS_VALIDITY"].present? ? Integer(ENV["AHOY_EVENTS_VALIDITY"]).months : 6.months
  end
end
