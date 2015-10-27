# == Schema Information
#
# Table name: choices
#
#  choice_set_id  :integer
#  created_at     :datetime         not null
#  id             :integer          not null, primary key
#  long_name      :json
#  long_name_old  :text
#  short_name     :json
#  short_name_old :string
#  updated_at     :datetime         not null
#

class Choice < ActiveRecord::Base
  belongs_to :choice_set

  validates_presence_of :choice_set
  validates_presence_of :long_name
  validates_presence_of :short_name

  def self.sorted(locale=I18n.locale)
    order("LOWER(choices.short_name->>'#{locale}') ASC")
  end
end
