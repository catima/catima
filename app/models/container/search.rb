# == Schema Information
#
# Table name: containers
#
#  content    :jsonb
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  locale     :string
#  page_id    :integer
#  row_order  :integer
#  slug       :string
#  type       :string
#  updated_at :datetime         not null
#

class Container::Search < Container
  store_accessor :content, :search, :display_type

  validates_presence_of :search
  validate :style_validation
  validate :uniqueness_validation

  def custom_container_permitted_attributes
    %i(search display_type)
  end

  # Return the display_type choices for the Search container
  def self.display_type_choices
    ::ItemList::STYLES.except("line")
  end

  private

  def style_validation
    return if display_type.empty?

    return if Container::Search.display_type_choices.key?(display_type)

    errors.add :display_type, "Style not allowed"
  end

  def uniqueness_validation
    return unless page.containers
                      .where.not(id: id)
                      .where(locale: locale)
                      .exists?(type: 'Container::Search')

    errors.add :base, I18n.t("validations.container.search.unique")
  end
end
