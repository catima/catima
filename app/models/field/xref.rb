# == Schema Information
#
# Table name: fields
#
#  category_item_type_id    :integer
#  choice_set_id            :integer
#  comment                  :text
#  created_at               :datetime         not null
#  default_value            :text
#  display_component        :string
#  display_in_list          :boolean          default(TRUE), not null
#  display_in_public_list   :boolean          default(TRUE), not null
#  editor_component         :string
#  field_set_id             :integer
#  field_set_type           :string
#  i18n                     :boolean          default(FALSE), not null
#  id                       :integer          not null, primary key
#  multiple                 :boolean          default(FALSE), not null
#  name_plural_translations :json
#  name_translations        :json
#  options                  :json
#  ordered                  :boolean          default(FALSE), not null
#  primary                  :boolean          default(FALSE), not null
#  related_item_type_id     :integer
#  required                 :boolean          default(TRUE), not null
#  restricted               :boolean          default(FALSE), not null
#  row_order                :integer
#  slug                     :string
#  type                     :string
#  unique                   :boolean          default(FALSE), not null
#  updated_at               :datetime         not null
#  uuid                     :string
#

class Field::Xref < ::Field
  include ::Field::AllowsMultipleValues

  # TODO: support :only and :exclude options

  store_accessor :options, :xref
  validates_presence_of :xref
  validate :xref_must_point_to_valid_service

  def type_name
    xref_type = external_type && external_type.name
    "Xref" + (xref_type ? " (#{xref_type})" : "")
  end

  def custom_field_permitted_attributes
    %i(xref)
  end

  def choices
    external_type ? external_type.all_items : []
  end

  def choice_by_id(id)
    external_type && external_type.find_item(id)
  end

  def selected_choices(item)
    return [] if raw_value(item).blank? || external_type.nil?

    Array.wrap(raw_value(item)).map do |id|
      begin
        external_type.find_item(id)
      rescue ExternalType::Client::NotFound
        nil
      end
    end.compact
  end

  def field_value_for_item(item)
    selected_choices(item).first&.name
  end

  def sql_type
    "VARCHAR(255)"
  end

  private

  def xref_must_point_to_valid_service
    return if xref.blank?

    if !xref.match? URI.regexp
      errors.add(:xref, :invalid_url)
    elsif external_type.nil?
      errors.add(:xref, "must point to a valid xref service")
    end
  end

  def external_type
    return nil if xref.blank?

    @external_type ||= begin
      ext = ExternalType.new(xref)
      ext.valid? ? ext : nil
    end
  end
end
