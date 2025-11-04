class CreateMaterialRequisitionItems < ActiveRecord::Migration[8.0]
  def change
    create_table :material_requisition_items do |t|
      t.references :material_requisition_slip, null: false, foreign_key: true
      t.references :material, null: false, foreign_key: true
      t.integer :quantity
      t.text :purpose

      t.timestamps
    end
  end
end
