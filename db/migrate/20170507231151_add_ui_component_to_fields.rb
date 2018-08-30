class AddUiComponentToFields < ActiveRecord::Migration[4.2]
  def change
    add_column :fields, :ui_component, :string
  end
end
