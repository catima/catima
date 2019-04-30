class AddSelfReferenceToChoice < ActiveRecord::Migration[5.2]
  def change
    add_reference :choices, :parent, :index => true
  end
end
