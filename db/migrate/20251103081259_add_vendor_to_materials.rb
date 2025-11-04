class AddVendorToMaterials < ActiveRecord::Migration[8.0]
  def change
    add_reference :materials, :vendor, null: false, foreign_key: true
  end
end
