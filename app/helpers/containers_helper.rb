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
    options = params if container.type_name == 'Search'

    "Container::#{container.type_name}Presenter".constantize.new(self, container, options)
  end

  def container_sort_field_options(container)
    return { type: nil, format: false } unless container.sort_field

    case container.sort_field.sort_type
    when :date
      { type: 'date', format: container.sort_field.effective_sort_field.format }
    when :numeric
      { type: 'num', format: false }
    else
      { type: '', format: false }
    end
  end
end
