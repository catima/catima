class UpdateEditorComponentForFieldChoiceSet < ActiveRecord::Migration[6.1]
  def change
    Field::ChoiceSet.update_all(editor_component: 'ChoiceSetInput')
  end
end
