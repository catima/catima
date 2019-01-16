# == Schema Information
#
# Table name: containers
#
#  content    :jsonb
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  locale     :string
#  page_id    :integer
#  row_order  :integer
#  slug       :string
#  type       :string
#  updated_at :datetime         not null
#

class Container::ItemList < ::Container
  store_accessor :content, :item_type, :style

  include ItemListsHelper

  def custom_container_permitted_attributes
    %i(item_type style)
  end

  def render_view(options={})
    catalog = Catalog.find_by(slug: options[:catalog_slug])
    @item_type = catalog.item_types.where(:id => item_type).first!
    @browse = ::ItemList::Filter.new(
      :item_type => @item_type,
      :page => options[:page]
    )
    render_item_list(@browse)
  end

  def describe
    super.merge('content' => { 'item_type' => item_type.nil? ? nil : ItemType.find(item_type).slug })
  end

  def update_from_json(json)
    unless json[:content].nil?
      it = catalog.item_types.find_by(slug: json[:content]['item_type'])
      json[:content]['item_type'] = it.id.to_s
    end
    super(json)
  end
end
