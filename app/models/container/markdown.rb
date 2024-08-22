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

class Container::Markdown < Container
  store_accessor :content, :markdown

  def custom_container_permitted_attributes
    %i(markdown)
  end

  def renderer(options={})
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      autolink: true, tables: true
    )
  end
end
