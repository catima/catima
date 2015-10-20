# == Schema Information
#
# Table name: items
#
#  catalog_id   :integer
#  created_at   :datetime         not null
#  creator_id   :integer
#  data         :json
#  id           :integer          not null, primary key
#  item_type_id :integer
#  reviewer_id  :integer
#  status       :string
#  updated_at   :datetime         not null
#

class Item < ActiveRecord::Base
  delegate :fields, :to => :item_type

  belongs_to :catalog
  belongs_to :item_type
  belongs_to :creator, :class_name => "User"
  belongs_to :reviewer, :class_name => "User"

  validates_presence_of :catalog
  validates_presence_of :creator
  validates_presence_of :item_type

  validates_inclusion_of :status,
                         :in => %w(ready rejected approved),
                         :allow_nil => true

  def behaving_as_type
    @behaving_as_type ||= becomes(typed_item_class)
  end

  private

  def typed_item_class
    typed = Class.new(Item)
    typed.define_singleton_method(:name) { Item.name }
    typed.define_singleton_method(:model_name) { Item.model_name }
    fields.each do |field|
      # TODO: allow field class to override/customize this
      typed.send(:store_accessor, :data, field.uuid)
    end
    typed
  end
end
