class AddDisplayInPublicListToFields < ActiveRecord::Migration[5.2]
  def up
    add_column :fields, :display_in_public_list, :boolean, :null => false, :default => true
    # rubocop:disable SkipsModelValidations
    Field.update_all("display_in_public_list=display_in_list")
    # rubocop:enable SkipsModelValidations
  end

  def down
    remove_column :fields, :display_in_public_list
  end
end
