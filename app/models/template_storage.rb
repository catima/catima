# == Schema Information
#
# Table name: template_storages
#
#  body       :text
#  created_at :datetime         not null
#  format     :string
#  handler    :string
#  id         :integer          not null, primary key
#  locale     :string
#  partial    :boolean
#  path       :string
#  updated_at :datetime         not null
#

class TemplateStorage < ApplicationRecord
  validates_presence_of :body
  validates_presence_of :format
  validates_presence_of :handler
  validates_presence_of :path

  store_templates
end
