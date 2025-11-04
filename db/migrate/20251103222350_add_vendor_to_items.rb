class AddVendorToItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :items, :vendor, null: true, foreign_key: true
  end
end
