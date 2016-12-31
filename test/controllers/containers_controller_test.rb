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

require 'test_helper'

class ContainersControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end
end
