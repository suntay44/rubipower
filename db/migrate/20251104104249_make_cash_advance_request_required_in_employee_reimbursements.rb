class MakeCashAdvanceRequestRequiredInEmployeeReimbursements < ActiveRecord::Migration[8.0]
  def change
    # First, delete any records without cash_advance_request_id (if any exist)
    execute "DELETE FROM employee_reimbursements WHERE cash_advance_request_id IS NULL"
    
    # Make cash_advance_request_id required
    change_column_null :employee_reimbursements, :cash_advance_request_id, false
  end
end
