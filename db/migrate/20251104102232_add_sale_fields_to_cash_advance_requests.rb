class AddSaleFieldsToCashAdvanceRequests < ActiveRecord::Migration[8.0]
  def change
    add_reference :cash_advance_requests, :sale, null: true, foreign_key: true
    add_column :cash_advance_requests, :project_name, :string
    add_column :cash_advance_requests, :description, :text
  end
end
