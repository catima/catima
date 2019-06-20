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
  belongs_to :user, optional: true

  def self.top(limit=5, from=3.months.ago, scope=nil)
    tops = select(:name).where(["time > ?", from])

    tops = tops.where('properties @> ?', { scope: scope }.to_json) if scope

    tops.group(:name)
        .count
        .sort_by(&:last)
        .reverse.first(limit)
  end
end
