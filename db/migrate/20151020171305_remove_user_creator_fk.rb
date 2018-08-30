class RemoveUserCreatorFk < ActiveRecord::Migration[4.2]
  def up
    remove_foreign_key "items", :column => "creator_id"
    remove_foreign_key "items", :column => "reviewer_id"
  end

  def down
    add_foreign_key "items", "users", :column => "creator_id"
    add_foreign_key "items", "users", :column => "reviewer_id"
  end
end
