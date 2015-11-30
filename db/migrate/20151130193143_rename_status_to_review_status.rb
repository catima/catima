class RenameStatusToReviewStatus < ActiveRecord::Migration
  def change
    rename_column :items, :status, :review_status
  end
end
