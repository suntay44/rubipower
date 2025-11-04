class RemoveManagerStatusFromCashAdvanceRequests < ActiveRecord::Migration[8.0]
  def change
    remove_column :cash_advance_requests, :manager_status, :string
    remove_column :cash_advance_requests, :manager_reject_notes, :text
    remove_column :cash_advance_requests, :manager_revise_notes, :text
  end
end
