# == Schema Information
#
# Table name: choices
#
#  id                      :integer          not null, primary key
#  from_date               :string
#  long_name_old           :text
#  long_name_translations  :json
#  position                :integer
#  short_name_old          :string
#  short_name_translations :json
#  to_date                 :string
#  uuid                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  catalog_id              :integer
#  category_id             :integer
#  choice_set_id           :integer
#  parent_id               :bigint
#
# Indexes
#
#  index_choices_on_catalog_id              (catalog_id)
#  index_choices_on_category_id             (category_id)
#  index_choices_on_choice_set_id           (choice_set_id)
#  index_choices_on_parent_id               (parent_id)
#  index_choices_on_uuid_and_choice_set_id  (uuid,choice_set_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (catalog_id => catalogs.id)
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (choice_set_id => choice_sets.id)
#  fk_rails_...  (parent_id => choices.id)
#

class Choice < ApplicationRecord
  include HasTranslations
  include Clone

  belongs_to :catalog
  belongs_to :category, optional: true
  belongs_to :choice_set, optional: true

  has_many :childrens, :class_name => Choice.to_s, foreign_key: 'parent_id', dependent: :destroy
  belongs_to :parent, :class_name => Choice.to_s, :optional => true

  store_translations :short_name, :required => true
  store_translations :long_name, :required => false

  scope :ordered, -> { order(:position) }

  validates_presence_of :catalog
  validate :validates_at_least_one_date_if_datation
  validate :validate_dates_are_positives
  validate :validate_category
  validate :validate_category_used

  before_create :assign_uuid
  after_destroy :reorder_on_destroy

  %w(de en fr it).each do |locale|
    define_method("long_display_name_#{locale}") do
      long_name = public_send("long_name_#{locale}")
      short_name = public_send("short_name_#{locale}")
      long_name.present? ? long_name : short_name
    end
  end

  def long_display_name(locale=I18n.locale)
    public_send("long_display_name_#{locale}")
  end

  def self.sorted(locale=I18n.locale)
    order(Arel.sql("LOWER(choices.short_name_translations->>'short_name_#{locale}') ASC"))
  end

  def self.short_named(name, locale=I18n.locale)
    where("choices.short_name_translations->>'short_name_#{locale}' = ?", name)
  end

  def describe
    as_json(only: %i(parent_id uuid short_name_translations long_name_translations))
      .merge(category: category.nil? ? nil : category.uuid)
  end

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def filterable_category_fields
    fields = []

    return fields unless category.present? && category.not_deleted?

    category.fields.each do |field|
      next unless field.sort_field?

      fields << field
    end

    fields
  end

  def self.sql_columns
    columns = {}

    Choice.columns_hash.each do |column_name, column|
      next if %w[choice_set_id long_name_old short_name_old catalog_id category_id].include?(column_name)

      columns[column_name] = column
    end

    columns
  end

  def save_with_position(position)
    Choice.transaction do
      parent = parent_id.present? ? choice_set.choices.find(parent_id) : nil
      case position
      when 'first'
        self.position = 1
        if parent
          parent.childrens.ordered.each_with_index do |choice, index|
            choice.update!(position: index + 2)
          end
        else
          choice_set.choices.where(parent_id: nil).ordered.each_with_index do |choice, index|
            choice.update!(position: index + 2)
          end
        end
      when 'last'
        last_position = parent ? parent.childrens.count + 1 : choice_set.choices.where(parent_id: nil).count + 1
        self.position = last_position
      end
      save
    end
  end

  private

  def reorder_on_destroy
    Choice.transaction do
      if parent.present?
        parent.childrens.ordered.each_with_index do |choice, index|
          choice.update!(position: index + 1)
        end
      else
        choice_set.choices.where(parent_id: nil).ordered.each_with_index do |choice, index|
          choice.update!(position: index + 1)
        end
      end
    end
  end

  def validate_dates_are_positives
    return unless choice_set&.datation?

    from_date_is_positive = JSON.parse(from_date).compact.select { |key, _value| key != 'BC' }.all? { |_key, value| value.to_i >= 0 }
    to_date_is_positive = JSON.parse(to_date).compact.select { |key, _value| key != 'BC' }.all? { |_key, value| value.to_i >= 0 }

    return if to_date_is_positive && from_date_is_positive

    errors.add(:base, :negative_dates)
  end

  def validates_at_least_one_date_if_datation
    return unless choice_set&.datation?

    from_date_components_presents = JSON.parse(from_date).compact.select { |key, value| key != 'BC' && value.to_i != 0 }.any?
    to_date_components_presents = JSON.parse(to_date).compact.select { |key, value| key != 'BC' && value.to_i != 0 }.any?

    return if from_date_components_presents || to_date_components_presents

    errors.add(:base, :dates_must_be_present)
  end

  def validate_category
    return if category.blank?

    return if category.not_deleted?

    errors.add :base, :category_deleted
  end

  def validate_category_used
    return if category.blank?

    # Check if the choice set is a field in the category.
    errors.add :base, :choise_set_present_in_category if category.fields.any? { |field| field.is_a?(Field::ChoiceSet) && field.choice_set_id == choice_set_id }

    # Get all the choices with the same category as the one we are trying to save
    choices = Choice.where(category_id: category, catalog_id: catalog)
                    .where.not(id: id)
                    .select { |choice| choice.choice_set.not_deleted? }

    return unless choices.any?

    # Check if choices with the same category are present in the same choice set
    same_choice_set = choices.any? do |choice|
      choice.choice_set == choice_set
    end

    # Check if choices with the same category are present in the same item type (field_set_id)
    same_item_types = (choices.flat_map do |choice|
      choice.choice_set.fields.map { |field| [field.field_set_id, field.field_set_type] }
    end.uniq & choice_set.fields.map { |field| [field.field_set_id, field.field_set_type] }).any?

    return unless same_item_types || same_choice_set

    errors.add :base, :category_already_used
  end
end
