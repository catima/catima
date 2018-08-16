class AddSearchColumnsToItems < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :search_data_de, :text
    add_column :items, :search_data_en, :text
    add_column :items, :search_data_fr, :text
    add_column :items, :search_data_it, :text
  end
end
