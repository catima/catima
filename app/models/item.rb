# == Schema Information
#
# Table name: items
#
#  catalog_id     :integer
#  created_at     :datetime         not null
#  creator_id     :integer
#  data           :jsonb
#  id             :integer          not null, primary key
#  item_type_id   :integer
#  review_status  :string           default("not-ready"), not null
#  reviewer_id    :integer
#  search_data_de :text
#  search_data_en :text
#  search_data_fr :text
#  search_data_it :text
#  updated_at     :datetime         not null
#  uuid           :string
#

# rubocop:disable ClassLength
class Item < ActiveRecord::Base
  include DataStore::Macros
  include Review::Macros
  include Search::Macros
  include HasHumanId

  human_id :primary_text_value

  delegate :field_for_select, :primary_field, :referenced_by_fields,
           :fields, :list_view_fields, :all_fields, :all_list_view_fields,
           :to => :item_type

  belongs_to :catalog
  belongs_to :item_type
  belongs_to :creator, :class_name => "User"

  validates_presence_of :catalog
  validates_presence_of :creator
  validates_presence_of :item_type
  validate :unique_value_fields

  # assign default and auto-increment field values
  after_initialize :assign_default_values
  before_validation :assign_autoincrement_values
  before_create :assign_uuid

  def self.sorted_by_field(field)
    sql = []
    sql << "data->>'#{field.uuid}' ASC" unless field.nil?
    sql << "created_at DESC"
    order(sql.join(", "))
  end

  def self.with_type(type)
    return all if type.nil?
    where(:item_type => type)
  end

  # The same as `all_fields`, but removes category-based fields that do not
  # apply to this item.
  def applicable_fields
    all_fields.select { |f| f.applicable_to_item(self) }
  end

  # The same as `all_list_view_fields`, but removes category-based fields that
  # do not apply to this item.
  def applicable_list_view_fields
    all_list_view_fields.select { |f| f.applicable_to_item(self) }
  end

  def behaving_as_type
    @behaving_as_type ||= begin
      casted = becomes(typed_item_class)
      # Clear errors so that it gets recreated pointed to the new casted item
      casted.instance_variable_set(:@errors, nil)
      casted
    end
  end

  # True if this item has an image as one of its list view fields.
  def image?
    list_view_fields.any? do |f|
      next unless f.is_a?(Field::Image)
      f.file_count(self) > 0
    end
  end

  def unique_value_fields
    return if self.item_type.nil?
    conn = ActiveRecord::Base.connection.raw_connection
    fields.each do |f|
      if f.unique
        sql = "SELECT COUNT(*) FROM items WHERE data->>'#{f.uuid}' = $1 AND item_type_id = $2"
        sql_data = [ self.data[f.uuid], self.item_type_id ]
        if self.id
          sql << " AND id <> $3"
          sql_data << self.id
        end
        res = conn.exec(sql, sql_data)
        n = res.getvalue(0,0).to_i
        if n > 0
          errors.add("#{f.uuid}".to_sym, "must be unique")
        end
      end
    end
  end

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end

  # Returns the value of the provided field for this item
  # field can be an instance of a field, a field UUID, or a field slug
  def get_value(field)
    field = item_type.find_field(field) unless field.is_a? Field
    field.value_for_item(self)
  end

  # Returns the value of the provided field for this item
  # if it is a simple item, or a ID (e.g. UUID or slug) for complex
  # fields. By default, it returns the same as get_value, but
  # subclasses can override this method
  def get_value_or_id(field)
    field = item_type.find_field(field) unless field.is_a? Field
    field.value_or_id_for_item(self)
  end

  # Returns a JSON representation of the item content.
  # It contains the field values for simple fields,
  # and an identifier for complex fields.
  def describe
    Hash[applicable_fields.collect { |f| [f.slug, get_value_or_id(f)] }] \
      .merge(catalog.requires_review ? { "review_status": review_status } : {}) \
      .merge("uuid": uuid)
  end

  # Sets the value of an item field by UUID
  def set_by_uuid(uuid, value)
    behaving_as_type.update(uuid => value)
  end

  private

  def primary_text_value
    field = item_type.primary_text_field
    field && field.raw_value(self)
  end

  def typed_item_class
    typed = Class.new(Item)
    typed.define_singleton_method(:name) { Item.name }
    typed.define_singleton_method(:model_name) { Item.model_name }
    all_fields.each { |f| f.decorate_item_class(typed) }
    typed
  end

  def assign_autoincrement_values
    return if item_type.nil?
    self.data = {} if self.data.nil?
    conn = ActiveRecord::Base.connection.raw_connection
    fields.each do |f|
      if (f.type == 'Field::Int') && !f.options.nil? && f.options['auto_increment'] && self.data[f.uuid].nil?
        st = conn.exec(
          "SELECT MAX(data->>'#{f.uuid}') FROM items WHERE item_type_id = $1",
          [ self.item_type_id, ]
        )
        self.data[f.uuid] = st.getvalue(0,0).to_i + 1
      end
    end
  end

  def assign_default_values
    return if self.id || self.item_type.nil?
    self.data = {} if self.data.nil?
    fields.each do |f|
      self.data[f.uuid] = f.default_value if f.default_value && !f.default_value.empty?
    end
  end
end
