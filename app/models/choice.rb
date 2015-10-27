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
  include HasI18nAccessors

  belongs_to :choice_set
  delegate :catalog, :to => :choice_set, :allow_nil => true
  i18n_accessors :short_name, :long_name
  validates_presence_of :choice_set

  def self.sorted(locale=I18n.locale)
    order("LOWER(choices.short_name->>'#{locale}') ASC")
  end
end
