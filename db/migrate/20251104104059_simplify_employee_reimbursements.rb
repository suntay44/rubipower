class SimplifyEmployeeReimbursements < ActiveRecord::Migration[8.0]
  def change
    # Add cash_advance_request reference
    add_reference :employee_reimbursements, :cash_advance_request, null: true, foreign_key: true
    
    # Rename fields
    rename_column :employee_reimbursements, :expense_purpose, :description
    rename_column :employee_reimbursements, :amount_claimed, :amount_to_reimburse
    
    # Remove unnecessary columns
    remove_column :employee_reimbursements, :employee_name, :string
    remove_column :employee_reimbursements, :employee_id, :string
    remove_column :employee_reimbursements, :expense_type, :integer
    remove_column :employee_reimbursements, :expense_date, :date
    remove_column :employee_reimbursements, :sales_order_number, :string
    remove_column :employee_reimbursements, :client_name, :string
    
    # Remove attachment columns (Active Storage handles these)
    # Note: The actual blobs are stored in active_storage_attachments, so we don't need to remove them here
  end
end
