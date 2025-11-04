class AddApprovalsToPurchaseRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :purchase_requests, :manager_approved, :boolean
    add_column :purchase_requests, :manager_approved_by, :integer
    add_column :purchase_requests, :manager_approved_at, :datetime
    add_column :purchase_requests, :finance_approved, :boolean
    add_column :purchase_requests, :finance_approved_by, :integer
    add_column :purchase_requests, :finance_approved_at, :datetime
    add_reference :purchase_requests, :material_requisition_slip, null: true, foreign_key: true
  end
end
