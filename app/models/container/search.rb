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

class Container::Search < ::Container
  store_accessor :content, :search, :display_type

  def custom_container_permitted_attributes
    %i(search display_type)
  end
end
