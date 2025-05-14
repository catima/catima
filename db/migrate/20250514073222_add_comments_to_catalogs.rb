class AddCommentsToCatalogs < ActiveRecord::Migration[7.2]
  def change
    add_column :catalogs, :comments, :text, null: true
  end
end
