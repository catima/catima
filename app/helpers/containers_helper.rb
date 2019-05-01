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

module ContainersHelper
  def container_html(container, options={})
    container_presenter(container, options).html
  end

  def container_presenter(container, options={})
    options = params if container.is_a?(Container::Search)

    "Container::#{container.type_name}Presenter".constantize.new(self, container, options)
  end
end
