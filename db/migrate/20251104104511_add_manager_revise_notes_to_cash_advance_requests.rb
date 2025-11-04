class AddManagerReviseNotesToCashAdvanceRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :cash_advance_requests, :manager_revise_notes, :text
  end
end
