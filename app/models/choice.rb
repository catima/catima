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
#  short_name_old          :string
#  short_name_translations :json
#  updated_at              :datetime         not null
#  uuid                    :string
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

  before_create :assign_uuid
  after_destroy :reorder_on_destroy

  %w(de en fr it).each do |locale|
    define_method("long_display_name_#{locale}") do
      long_name = public_send("long_name_#{locale}")
      short_name = public_send("short_name_#{locale}")
      long_name.present? ? long_name : short_name
    end
  end

  def long_display_name(locale = I18n.locale)
    public_send("long_display_name_#{locale}")
  end

  def self.sorted(locale = I18n.locale)
    order(Arel.sql("LOWER(choices.short_name_translations->>'short_name_#{locale}') ASC"))
  end

  def self.short_named(name, locale = I18n.locale)
    where("choices.short_name_translations->>'short_name_#{locale}' = ?", name)
  end

  def describe
    as_json(only: %i(parent_id uuid short_name_translations long_name_translations)) \
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
end
