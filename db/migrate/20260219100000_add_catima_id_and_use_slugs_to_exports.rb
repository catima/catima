class AddCatimaIdAndUseSlugsToExports < ActiveRecord::Migration[7.0]
  def change
    add_column :exports, :with_catima_id, :boolean, null: false, default: false
    add_column :exports, :use_slugs, :boolean, null: false, default: false
  end
end
