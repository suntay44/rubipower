class AddMaterialRequisitionSlipToItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :items, :material_requisition_slip, null: true, foreign_key: true
  end
end
