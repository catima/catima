# == Schema Information
#
# Table name: searches
#
#  created_at          :datetime         not null
#  id                  :bigint(8)        not null, primary key
#  name                :string
#  related_search_id   :bigint(8)
#  related_search_type :string
#  updated_at          :datetime         not null
#  user_id             :bigint(8)
#

class Search < ApplicationRecord
  delegate :catalog, :to => :related_search
  delegate :locale, :to => :related_search
  delegate :uuid, :to => :related_search

  belongs_to(
    :user,
    -> { unscope(where: :deleted_at) },
    inverse_of: :searches
  )
  belongs_to :related_search, polymorphic: true

  validates_presence_of :user
  validates_presence_of :related_search

  def search_name
    name.presence || ApplicationController.helpers.search_name(self)
  end
end
