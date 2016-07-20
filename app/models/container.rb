# == Schema Information
#
# Table name: containers
#
#  content    :jsonb
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  page_id    :integer
#  row_order  :integer
#  slug       :string
#  type       :string
#  updated_at :datetime         not null
#

class Container < ActiveRecord::Base
  TYPES = {
    html: 'Container::HTML',
    markdown: 'Container::Markdown',
    itemlist: "Container::ItemList"
  }.freeze

  #include HasSlug
  include RankedModel

  belongs_to :page

  ranks :row_order, :with_same => :page_id

  validates_presence_of :page_id
  validates_presence_of :content
  #validates_slug :scope => :page_id

  def self.sorted
    rank(:row_order)
  end

  def self.policy_class
    ContainerPolicy
  end

  def self.type_choices
    Container::TYPES.map do |key, class_name|
      [key, class_name.constantize.new.type_name]
    end.sort_by(&:last)
  end

  def type_name
    type.gsub(/Container::/, '')
  end

  def partial_name
    model_name.singular.sub(/^container_/, '')
  end

  def custom_container_permitted_attributes
    []
  end

  def render
    '<p style="color:#f00;">Subclasses of Container must implement a render method'
  end
end
