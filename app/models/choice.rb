# == Schema Information
#
# Table name: choices
#
#  choice_set_id           :integer
#  created_at              :datetime         not null
#  id                      :integer          not null, primary key
#  long_name_old           :text
#  long_name_translations  :json
#  short_name_old          :string
#  short_name_translations :json
#  updated_at              :datetime         not null
#

class Choice < ActiveRecord::Base
  include HasTranslations

  belongs_to :choice_set
  delegate :catalog, :to => :choice_set, :allow_nil => true
  store_translations :short_name, :long_name
  validates_presence_of :choice_set

  def self.sorted(locale=I18n.locale)
    order("LOWER(choices.short_name_translations->>'#{locale}') ASC")
  end
end
