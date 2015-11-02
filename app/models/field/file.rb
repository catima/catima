# == Schema Information
#
# Table name: fields
#
#  category_item_type_id    :integer
#  choice_set_id            :integer
#  comment                  :text
#  created_at               :datetime         not null
#  default_value            :text
#  display_in_list          :boolean          default(TRUE), not null
#  i18n                     :boolean          default(FALSE), not null
#  id                       :integer          not null, primary key
#  item_type_id             :integer
#  multiple                 :boolean          default(FALSE), not null
#  name_old                 :string
#  name_plural_old          :string
#  name_plural_translations :json
#  name_translations        :json
#  options                  :json
#  ordered                  :boolean          default(FALSE), not null
#  primary                  :boolean          default(FALSE), not null
#  related_item_type_id     :integer
#  required                 :boolean          default(TRUE), not null
#  row_order                :integer
#  slug                     :string
#  type                     :string
#  unique                   :boolean          default(FALSE), not null
#  updated_at               :datetime         not null
#  uuid                     :string
#

class Field::File < ::Field
  store_accessor :options, :types

  after_initialize :set_default_types
  validates_presence_of :types

  def custom_field_permitted_attributes
    %i(types)
  end

  def custom_item_permitted_attributes
    [:"remove_#{uuid}"]
  end

  def allowed_extensions
    types.to_s.split(/[,\s]+/).map do |token|
      token.strip[/^\.?(\S+)/, 1]
    end
  end

  def decorate_item_class(klass)
    super
    klass.data_store_hash(uuid, :id, :filename, :size)
    klass.send(:attachment, uuid, :extension => allowed_extensions)
  end

  def attachment_present?(item)
    item.behaving_as_type.public_send("#{uuid}_id").present?
  end

  def attachment_filename(item)
    item.behaving_as_type.public_send("#{uuid}_filename")
  end

  def attachment_size(item)
    item.behaving_as_type.public_send("#{uuid}_size")
  end

  private

  def set_default_types
    return if persisted? || types.present?
    self.types = "jpg jpeg png gif"
  end
end
