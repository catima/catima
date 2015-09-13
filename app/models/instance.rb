class Instance < ActiveRecord::Base
  has_many :schema_elements
  has_many :views
end
