class RemoveSignatureFieldsFromCashAdvanceRequests < ActiveRecord::Migration[8.0]
  def change
    remove_column :cash_advance_requests, :prepare_name, :string, if_exists: true
    remove_column :cash_advance_requests, :prepare_date, :date, if_exists: true
    remove_column :cash_advance_requests, :approval_name, :string, if_exists: true
    remove_column :cash_advance_requests, :approval_date, :date, if_exists: true
    remove_column :cash_advance_requests, :release_name, :string, if_exists: true
    remove_column :cash_advance_requests, :release_date, :date, if_exists: true
    remove_column :cash_advance_requests, :receive_name, :string, if_exists: true
    remove_column :cash_advance_requests, :receive_date, :date, if_exists: true
  end
end
