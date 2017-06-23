class RenameUiToEditorComponent < ActiveRecord::Migration
  def change
    rename_column(:fields, :ui_component, :editor_component)
  end
end
