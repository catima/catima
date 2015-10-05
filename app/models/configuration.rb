# == Schema Information
#
# Table name: configurations
#
#  created_at         :datetime         not null
#  default_catalog_id :integer
#  id                 :integer          not null, primary key
#  root_mode          :string           default("listing"), not null
#  updated_at         :datetime         not null
#

class Configuration < ActiveRecord::Base
  belongs_to :default_catalog, :class_name => "Catalog"
  validates_presence_of :root_mode
  validates_inclusion_of :root_mode, :in => %w(listing custom redirect)
end
