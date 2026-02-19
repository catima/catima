# == Schema Information
#
# Table name: api_logs
#
#  id         :bigint           not null, primary key
#  endpoint   :string
#  payload    :json
#  remote_ip  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  catalog_id :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_api_logs_on_catalog_id  (catalog_id)
#  index_api_logs_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class APILog < ApplicationRecord
  belongs_to :user, -> { unscope(where: :deleted_at) }, inverse_of: :api_logs
  belongs_to :catalog, optional: true

  scope :ordered, -> { order(created_at: :desc) }

  def self.validity
    ENV["API_LOGS_VALIDITY"].present? ? Integer(ENV["API_LOGS_VALIDITY"]).months : 4.months
  end
end
