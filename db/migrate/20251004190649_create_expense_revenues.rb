class CreateExpenseRevenues < ActiveRecord::Migration[8.0]
  def change
    create_table :expense_revenues do |t|
      t.date :expense_date
      t.string :vendor_name
      t.text :vendor_address
      t.string :vendor_tin
      t.text :purpose
      t.decimal :amount
      t.date :receipt_date
      t.string :po_number
      t.string :rfp_number
      t.string :bank_reference
      t.decimal :quantity
      t.decimal :unit_price
      t.integer :category
      t.string :sales_order_number
      t.string :client_name
      t.integer :supervisor_status
      t.integer :finance_status
      t.text :supervisor_comments
      t.text :finance_comments
      t.references :verified_by, null: true, foreign_key: { to_table: :users }
      t.datetime :verified_at
      t.references :requester_user, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :expense_revenues, :supervisor_status
    add_index :expense_revenues, :finance_status
    add_index :expense_revenues, :category
    add_index :expense_revenues, :expense_date
  end
end
