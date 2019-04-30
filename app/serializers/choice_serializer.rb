# == Schema Information
#
# Table name: choices
#
#  catalog_id              :integer
#  category_id             :integer
#  choice_set_id           :integer
#  created_at              :datetime         not null
#  id                      :integer          not null, primary key
#  long_name_old           :text
#  long_name_translations  :json
#  parent_id               :bigint(8)
#  row_order               :integer
#  short_name_old          :string
#  short_name_translations :json
#  synonyms                :jsonb
#  updated_at              :datetime         not null
#  uuid                    :string
#

class ChoiceSerializer < ActiveModel::Serializer
  attributes :uuid, :short_name_translations, :long_name_translations, :category_id
  has_many :children, :serializer => ChoiceSerializer
end
