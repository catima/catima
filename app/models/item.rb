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
#  updater_id     :integer
#  uuid           :string
#  views          :jsonb
#

class Item < ApplicationRecord
  include DataStore::Macros
  include Item::Values
  include Review::Macros
  include Search::Macros
  include HasHumanId
  include Loggable

  human_id :primary_text_value

  delegate :field_for_select, :primary_field, :referenced_by_fields,
           :fields, :list_view_fields, :all_fields, :all_public_list_view_fields, :all_list_view_fields,
           :simple_fields, :to => :item_type

  belongs_to :catalog
  belongs_to :item_type
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User", optional: true
  has_many :favorites, :dependent => :destroy
  has_many :suggestions, :dependent => :destroy

  validates_presence_of :catalog
  validates_presence_of :creator
  validates_presence_of :item_type
  validate :unique_value_fields

  # assign default and auto-increment field values
  after_initialize :assign_default_values
  after_initialize :assign_autoincrement_values
  before_create :assign_uuid

  def log_name
    item_type.primary_text_field&.raw_value(self) || ''
  end

  # TODO: uncomment when item cache worker is fixed
  # after_commit :update_views_cache, if: proc { |record| record.saved_changes.key?(:data) }

  def self.sorted_by_field(field, direction: "ASC", nulls_order: 'LAST')
    direction = ItemList::Sort.included?(direction) ? direction : ItemList::Sort.ascending
    sql = []
    sql << field.order_items_by(direction: direction, nulls_order: nulls_order) unless field.nil?

    if field.nil? ||
       (field.type != Field::TYPES['reference'] && field.type != Field::TYPES['choice'])
      return reorder(Arel.sql(sql.join(", ")))
    end

    sorted_by_ref_or_choice(sql, field)
  end

  def self.sorted_by_ref_or_choice(sql, field)
    if field.type == Field::TYPES['reference']
      return joins("LEFT JOIN items ref_items ON ref_items.id::text = items.data->>'#{field.uuid}'")
             .reorder(
               Arel.sql(sql.join(", "))
             )
    end

    return unless field.type == Field::TYPES['choice']

    joins("LEFT JOIN choices choices_#{field.uuid} ON choices_#{field.uuid}.id::text = items.data->>'#{field.uuid}' ")
      .reorder(
        Arel.sql(sql.map { |s| s.gsub('choices', "choices_#{field.uuid}") }.join(", "))
      )
  end

  def self.sorted_by_created_at(direction: "ASC")
    reorder(
      Arel.sql(
        "items.created_at #{direction}"
      )
    )
  end

  def self.sorted_by_updated_at(direction: "ASC")
    reorder(
      Arel.sql(
        "items.updated_at #{direction}"
      )
    )
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
    all_public_list_view_fields.select { |f| f.applicable_to_item(self) }
  end

  def behaving_as_type
    @behaving_as_type ||= begin
      casted = becomes(typed_item_class)
      # Clear errors so that it gets recreated pointed to the new casted item
      casted.instance_variable_set(:@errors, nil)
      casted
    end
  end

  # True if this item has a public displayable image as one of its fields.
  def image?
    fields.any? do |f|
      next unless f.is_a?(Field::Image) && f.display_in_public_list

      f.file_count(self) > 0
    end
  end

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end

  # Returns a JSON representation of the item content.
  # It contains the field values for simple fields,
  # and an identifier for complex fields.
  # rubocop:disable Style/OptionalBooleanParameter
  def describe(includes=[], excludes=[], for_api=false)
    d = applicable_fields.to_h { |f| [f.slug, get_value_or_id(f, for_api)] } \
                         .merge(id: id) \
                         .merge(review_status: review_status) \
                         .merge(uuid: uuid)

    includes.each { |i| d[i] = public_send(i) }
    excludes.each { |e| d.delete(e) }

    d
  end
  # rubocop:enable Style/OptionalBooleanParameter

  # Sets the value of an item field by UUID
  def set_by_uuid(uuid, value)
    behaving_as_type.update(uuid => value)
  end

  def default_display_name(locale=I18n.locale)
    v = views && views["display_name"] && views["display_name"][locale.to_s]
    return v unless v.nil?

    field = field_for_select
    return '' if field.nil?

    field.field_value_for_item(self)
  end

  def view(type, locale=I18n.locale)
    (views[type.to_s] && views[type.to_s][locale.to_s]) || default_display_name(locale)
  end

  private

  def typed_item_class
    typed = Class.new(Item)
    typed.define_singleton_method(:name) { Item.name }
    typed.define_singleton_method(:model_name) { Item.model_name }
    all_fields.each { |f| f.decorate_item_class(typed) }
    typed
  end

  def update_views_cache
    ItemsCacheWorker.perform_async(catalog.slug, item_type.slug, id)
  end

  def assign_default_values
    return if id || item_type.nil?

    self.data = {} if data.nil?
    fields.each do |f|
      next if f.default_value.blank?

      # In some cases, data are already setted when this assignation occurs.
      # In these cases, we do not override already setted data.
      next if data.key?(f.uuid)

      self.data[f.uuid] = f.default_value
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def assign_autoincrement_values
    return if id || item_type.nil?

    self.data = {} if data.nil?
    conn = ActiveRecord::Base.connection.raw_connection
    fields.each do |f|
      next unless (f.type == 'Field::Int') && !f.options.nil? && f.auto_increment? && data[f.uuid].nil?

      st = conn.exec(
        "SELECT MAX(CAST(NULLIF(data->>'#{f.uuid}', '') AS integer)) FROM items WHERE item_type_id = $1",
        [item_type_id]
      )
      self.data[f.uuid] = st.getvalue(0, 0).to_i + 1
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
