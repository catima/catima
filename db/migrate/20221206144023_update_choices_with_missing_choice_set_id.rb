class UpdateChoicesWithMissingChoiceSetId < ActiveRecord::Migration[6.1]
  def change
    Choice.where(choice_set_id: nil).where.not(parent_id: nil).find_each do |choice|
      choice.update(choice_set_id: choice.parent.choice_set_id)
    end
  end
end
