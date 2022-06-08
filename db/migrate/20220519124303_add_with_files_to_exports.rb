class AddWithFilesToExports < ActiveRecord::Migration[6.1]
  def change
    add_column :exports, :with_files, :boolean, :null => false, :default => true
  end
end
