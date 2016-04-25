class AddCustomRootPageToCatalogs < ActiveRecord::Migration
  def change
    add_column :catalogs, :custom_root_page_id, :integer, :index => true

    add_foreign_key "catalogs",
                    "pages",
                    :column => "custom_root_page_id"
  end
end
