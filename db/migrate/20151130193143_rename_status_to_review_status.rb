class RenameStatusToReviewStatus < ActiveRecord::Migration[4.2]
  def change
    rename_column :items, :status, :review_status
  end
end
