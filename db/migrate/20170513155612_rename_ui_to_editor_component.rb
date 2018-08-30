class RenameUiToEditorComponent < ActiveRecord::Migration[4.2]
  def change
    rename_column(:fields, :ui_component, :editor_component)
  end
end
