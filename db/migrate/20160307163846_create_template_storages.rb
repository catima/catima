class CreateTemplateStorages < ActiveRecord::Migration
  def change
    create_table :template_storages do |t|
      t.text :body
      t.string :path
      t.string :locale
      t.string :handler
      t.boolean :partial
      t.string :format

      t.timestamps null: false
    end
  end
end
