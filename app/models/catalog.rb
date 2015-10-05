# == Schema Information
#
# Table name: catalogs
#
#  created_at       :datetime         not null
#  deactivated_at   :datetime
#  id               :integer          not null, primary key
#  name             :string
#  other_languages  :json
#  primary_language :string           default("en"), not null
#  requires_review  :boolean          default(FALSE), not null
#  slug             :string
#  updated_at       :datetime         not null
#

class Catalog < ActiveRecord::Base
end
