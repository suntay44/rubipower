class AddSignatureFieldsToCashAdvanceRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :cash_advance_requests, :prepare_name, :string
    add_column :cash_advance_requests, :prepare_date, :date
    add_column :cash_advance_requests, :approval_name, :string
    add_column :cash_advance_requests, :approval_date, :date
    add_column :cash_advance_requests, :release_name, :string
    add_column :cash_advance_requests, :release_date, :date
    add_column :cash_advance_requests, :receive_name, :string
    add_column :cash_advance_requests, :receive_date, :date
  end
end
