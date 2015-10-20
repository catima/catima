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
  delegate :fields, :primary_field, :to => :item_type

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

  def self.sorted_by_field(field)
    sql = []
    sql << "data->>'#{field.uuid}' ASC" unless field.nil?
    sql << "created_at DESC"
    order(sql.join(", "))
  end

  def behaving_as_type
    @behaving_as_type ||= begin
      casted = becomes(typed_item_class)
      # Clear errors so that it gets recreated pointed to the new casted item
      casted.instance_variable_set(:@errors, nil)
      casted
    end
  end

  def display_name
    field = primary_field || fields.first
    return to_s if field.nil?
    behaving_as_type.public_send(field.uuid)
  end

  private

  def typed_item_class
    typed = Class.new(Item)
    typed.define_singleton_method(:name) { Item.name }
    typed.define_singleton_method(:model_name) { Item.model_name }
    fields.each { |f| f.decorate_item_class(typed) }
    typed
  end
end
