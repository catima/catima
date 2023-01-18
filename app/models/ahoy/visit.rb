# == Schema Information
#
# Table name: ahoy_visits
#
#  app_version      :string
#  browser          :string
#  city             :string
#  country          :string
#  device_type      :string
#  id               :bigint(8)        not null, primary key
#  ip               :string
#  landing_page     :text
#  latitude         :decimal(10, 8)
#  longitude        :decimal(11, 8)
#  os               :string
#  os_version       :string
#  platform         :string
#  referrer         :text
#  referring_domain :string
#  region           :string
#  started_at       :datetime
#  user_agent       :text
#  user_id          :bigint(8)
#  utm_campaign     :string
#  utm_content      :string
#  utm_medium       :string
#  utm_source       :string
#  utm_term         :string
#  visit_token      :string
#  visitor_token    :string
#

class Ahoy::Visit < ApplicationRecord
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event", dependent: :nullify
  belongs_to :user, -> { unscope(where: :deleted_at) }, optional: true

  def self.validity
    ENV["AHOY_VISITS_VALIDITY"].present? ? Integer(ENV["AHOY_VISITS_VALIDITY"]).months : 6.months
  end
end
