class AddSuggestionsActivatedToItemTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :item_types, :suggestions_activated, :boolean, default: false
    add_column :item_types, :suggestion_email, :string
    add_column :item_types, :allow_anonymous_suggestions, :boolean, default: false
  end
end
