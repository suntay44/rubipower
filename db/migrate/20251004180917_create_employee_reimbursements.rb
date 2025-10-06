class CreateEmployeeReimbursements < ActiveRecord::Migration[8.0]
  def change
    create_table :employee_reimbursements do |t|
      t.string :employee_name
      t.string :employee_id
      t.integer :expense_type, default: 0
      t.text :expense_purpose
      t.decimal :amount_claimed, precision: 10, scale: 2
      t.date :expense_date
      t.string :sales_order_number
      t.string :client_name
      t.integer :supervisor_status, default: 0
      t.text :supervisor_comments
      t.integer :finance_status, default: 0
      t.text :finance_comments
      t.integer :payment_method
      t.date :payment_processed_date
      t.references :requester_user, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :employee_reimbursements, :supervisor_status
    add_index :employee_reimbursements, :finance_status
    add_index :employee_reimbursements, :expense_type
  end
end
