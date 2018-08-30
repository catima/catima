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

class Container::HTML < ::Container
  store_accessor :content, :html

  def custom_container_permitted_attributes
    %i(html)
  end

  def render_view(options={})
    content['html']
  end
end
