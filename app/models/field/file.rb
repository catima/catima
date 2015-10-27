# == Schema Information
#
# Table name: fields
#
#  category_item_type_id :integer
#  choice_set_id         :integer
#  comment               :text
#  created_at            :datetime         not null
#  default_value         :text
#  display_in_list       :boolean          default(TRUE), not null
#  i18n                  :boolean          default(FALSE), not null
#  id                    :integer          not null, primary key
#  item_type_id          :integer
#  multiple              :boolean          default(FALSE), not null
#  name                  :string
#  name_plural           :string
#  options               :json
#  ordered               :boolean          default(FALSE), not null
#  primary               :boolean          default(FALSE), not null
#  related_item_type_id  :integer
#  required              :boolean          default(TRUE), not null
#  row_order             :integer
#  slug                  :string
#  type                  :string
#  unique                :boolean          default(FALSE), not null
#  updated_at            :datetime         not null
#  uuid                  :string
#

class Field::File < ::Field
  store_accessor :options, :types

  validates_presence_of :types

  def custom_permitted_attributes
    %i(types)
  end

  def allowed_extensions
    types.to_s.split(/[,\s]+/).map do |token|
      token.strip[/^\.?(\S+)/, 1]
    end
  end

  def decorate_item_class(klass)
    super
    define_attachment_accessors(klass)
    klass.send(:attachment, uuid)
  end

  %w(id filename size).each do |attr|
    define_method("attachment_#{attr}") do |item|
      attachment_metadata(item)[attr]
    end
    define_method("attachment_#{attr}=") do |item, value|
      attachment_metadata(item)[attr] = value
    end
  end

  def attachment_metadata(item)
    read_value(item) || write_value(item, {})
  end

  private

  def define_attachment_accessors(klass)
    field = self
    %w(id filename size).each do |attr|
      klass.send(:define_method, "#{uuid}_#{attr}") do
        field.public_send("attachment_#{attr}", self)
      end
      klass.send(:define_method, "#{uuid}_#{attr}=") do |value|
        field.public_send("attachment_#{attr}=", self, value)
      end
      klass.send(:define_method, "#{uuid}_#{attr}_will_change!") do
        nil
      end
    end
  end
end
