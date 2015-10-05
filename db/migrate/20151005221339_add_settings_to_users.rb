class AddSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :system_admin, :boolean,
               :null => false, :default => false

    add_column :users, :primary_language, :string,
               :null => false, :default => "en"
  end
end
