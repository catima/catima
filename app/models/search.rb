# == Schema Information
#
# Table name: searches
#
#  id                  :bigint           not null, primary key
#  name                :string
#  related_search_type :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  related_search_id   :bigint
#  user_id             :bigint
#
# Indexes
#
#  index_searches_on_related_search_type_and_related_search_id  (related_search_type,related_search_id)
#  index_searches_on_user_id                                    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
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
