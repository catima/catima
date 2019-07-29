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

class Choice < ApplicationRecord
  include RankedModel
  include HasTranslations

  ranks :row_order, with_same: [:parent_id]

  belongs_to :catalog
  belongs_to :category, optional: true
  belongs_to :choice_set, optional: true
  belongs_to :parent, :class_name => "Choice", :optional => true
  has_many :children, -> { order(:row_order) }, :class_name => "Choice", :dependent => :destroy, :foreign_key => 'parent_id', :inverse_of => false

  store_translations :short_name, :required => true
  store_translations :long_name, :required => false

  validates_presence_of :catalog

  before_create :assign_uuid

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
    ChoiceSerializer.new(self).as_json
  end

  def assign_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def filterable_category_fields
    fields = []

    return fields unless category.present? && category.active?

    category.fields.each do |field|
      next unless field.filterable_field?

      fields << field
    end

    fields
  end

  # Used in the advanced search
  def children_as_options
    options = {
      :value => short_name_with_synonyms,
      :key => id,
      :children => []
    }

    children.each do |child|
      options[:children] << child.children_as_options
    end

    options
  end

  # Used in show item
  def top_parent_to_self
    choice = self
    return [locale_synonyms(choice)] if parent.nil?

    choices = []
    loop do
      c = choice.short_name
      c << " (#{locale_synonyms(choice)})" if locale_synonyms(choice).present?
      choices << c

      break if choice.parent.blank?

      choice = choice.parent
    end

    choices.reverse
  end

  def short_name_with_synonyms
    "#{short_name} #{concat_synonyms}"
  end

  def concat_synonyms
    return "" if synonyms.blank?

    syn = " | "
    synonyms.each do |synonym|
      syn << "#{synonym[I18n.locale.to_s]} | "
    end

    syn.chomp(" | ")
  end

  private

  def locale_synonyms(choice)
    synonyms = choice.synonyms&.map { |s| s[I18n.locale.to_s] }
    synonyms&.join(", ")
  end
end
