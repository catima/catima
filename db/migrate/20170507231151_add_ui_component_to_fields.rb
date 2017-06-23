class AddUiComponentToFields < ActiveRecord::Migration
  def change
    add_column :fields, :ui_component, :string
  end
end
