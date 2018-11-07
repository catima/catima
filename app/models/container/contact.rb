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

class Container::Contact < ::Container
  store_accessor :content, :receiving_email, :name, :email, :subject, :body

  def custom_container_permitted_attributes
    %i(receiving_email name email subject body)
  end
end
