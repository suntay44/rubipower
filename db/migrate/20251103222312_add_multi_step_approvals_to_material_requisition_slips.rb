class AddMultiStepApprovalsToMaterialRequisitionSlips < ActiveRecord::Migration[8.0]
  def change
    add_column :material_requisition_slips, :supervisor_approved, :boolean, default: false
    add_column :material_requisition_slips, :supervisor_approved_by, :integer
    add_column :material_requisition_slips, :supervisor_approved_at, :datetime
    add_column :material_requisition_slips, :procurement_approved, :boolean, default: false
    add_column :material_requisition_slips, :procurement_approved_by, :integer
    add_column :material_requisition_slips, :procurement_approved_at, :datetime
    add_column :material_requisition_slips, :engineering_approved, :boolean, default: false
    add_column :material_requisition_slips, :engineering_approved_by, :integer
    add_column :material_requisition_slips, :engineering_approved_at, :datetime
    add_column :material_requisition_slips, :manager_approved, :boolean, default: false
    add_column :material_requisition_slips, :manager_approved_by, :integer
    add_column :material_requisition_slips, :manager_approved_at, :datetime
    add_column :material_requisition_slips, :admin_approved, :boolean, default: false
    add_column :material_requisition_slips, :admin_approved_by, :integer
    add_column :material_requisition_slips, :admin_approved_at, :datetime
    add_column :material_requisition_slips, :lead_time, :integer
  end
end
