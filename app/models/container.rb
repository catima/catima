# == Schema Information
#
# Table name: containers
#
#  id            :integer          not null, primary key
#  content       :jsonb
#  field_format  :string
#  locale        :string
#  row_order     :integer
#  slug          :string
#  sort          :string
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  page_id       :integer
#  sort_field_id :integer
#
# Indexes
#
#  index_containers_on_page_id  (page_id)
#  index_containers_on_slug     (slug)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => pages.id)
#

class Container < ApplicationRecord
  TYPES = {
    "html" => 'Container::HTML',
    "markdown" => 'Container::Markdown',
    "itemlist" => 'Container::ItemList',
    "map" => 'Container::Map',
    "contact" => 'Container::Contact',
    "search" => 'Container::Search'
  }.freeze

  include Container::Sort
  include RankedModel
  ranks :row_order, :class_name => "Container", :with_same => %i(page_id locale)

  belongs_to :page

  validates_presence_of :page_id
  validates_presence_of :content
  validates_presence_of :locale

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

  def catalog
    page.catalog
  end

  def type_name
    type.gsub("Container::", '')
  end

  def partial_name
    model_name.singular.sub(/^container_/, '')
  end

  def custom_container_permitted_attributes
    []
  end

  def render_view(options={})
    # TODO: delegate rendering to a presenter class outside of the model
    '<p style="color:#f00;">Subclasses of Container must implement a render method'
  end

  def describe
    as_json(only: %i(type slug content locale row_order))
  end

  def update_from_json(d)
    update(d)
  end

  def sort_field
    sort_field_id? ? Field.find_by(id: sort_field_id) : nil
  end
end
