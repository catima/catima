# Mixin that adds search functionality using the pg_search macro. Actual
# indexing and searching logic is delegated to the Search::Index and
# ItemList::AdvancedSearchResult classes. This module serves as the glue
# between those classes and the Item model.
module Search::Macros
  PG_DICTIONARIES = {
    "de" => "german",
    "en" => "english",
    "fr" => "french",
    "it" => "italian"
  }.freeze

  extend ActiveSupport::Concern
  include PgSearch::Model

  included do
    # Define a `simple_search` scope that searches the current locale
    pg_search_scope :simple_search, ->(query) { simple_search_config(query) }

    # Update the `search_data_#{locale}` columns whenever Item is saved
    before_save :assign_search_data
  end

  module ClassMethods
    # Reindex all Items. Can be limited in scope: `Item.where(...).reindex`.
    def reindex
      find_each do |item|
        item.update_columns(item.recalculate_search_data)
      end
    end

    private

    def simple_search_config(query)
      {
        :query => query,
        :against => "search_data_#{I18n.locale}",
        :using => {
          :tsearch => {
            :prefix => true,
            :dictionary => PG_DICTIONARIES.fetch(I18n.locale.to_s, "simple")
          }
        }
      }
    end
  end

  def recalculate_search_data
    I18n.available_locales.each_with_object({}) do |locale, attrs|
      index = Search::Index.new(:item => behaving_as_type, :locale => locale)
      attrs["search_data_#{locale}"] = index.data
    end
  end

  private

  def assign_search_data
    assign_attributes(recalculate_search_data)
  end
end
