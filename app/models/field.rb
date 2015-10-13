# == Schema Information
#
# Table name: fields
#
#  category_item_type_id :integer
#  choice_set_id         :integer
#  comment               :text
#  created_at            :datetime         not null
#  default_value         :text
#  i18n                  :boolean          default(FALSE), not null
#  id                    :integer          not null, primary key
#  item_type_id          :integer
#  multiple              :boolean          default(FALSE), not null
#  name                  :string
#  name_plural           :string
#  options               :json
#  ordered               :boolean          default(FALSE), not null
#  position              :integer          default(0), not null
#  related_item_type_id  :integer
#  required              :boolean          default(TRUE), not null
#  slug                  :string
#  type                  :string
#  unique                :boolean          default(FALSE), not null
#  updated_at            :datetime         not null
#

class Field < ActiveRecord::Base
  include HasSlug

  belongs_to :item_type
  belongs_to :category_item_type, :class_name => "ItemType"
  belongs_to :related_item_type, :class_name => "ItemType"
  belongs_to :choice_set

  validates_presence_of :item_type
  validates_presence_of :name
  validates_presence_of :name_plural
  validates_slug :scope => :item_type_id
end
