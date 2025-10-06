class CreateCashAdvanceRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :cash_advance_requests do |t|
      t.string :employee_name, null: false
      t.string :employee_id, null: false
      t.string :department, null: false
      t.string :sales_order_number
      t.string :client_name
      t.text :purpose_of_advance, null: false
      t.text :breakdown_of_expenses, null: false
      t.decimal :amount_requested, precision: 10, scale: 2, null: false
      t.date :request_date, null: false
      t.date :required_date, null: false
      t.text :supporting_documents
      t.string :manager_status, default: 'pending'
      t.text :manager_reject_notes
      t.string :finance_department_status, default: 'pending'
      t.text :finance_department_documentation_notes
      t.references :requester_user, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
