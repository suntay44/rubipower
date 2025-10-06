class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.integer :invoice_type, default: 0
      t.string :company_name
      t.text :company_address
      t.string :company_contact
      t.string :client_name
      t.string :client_company
      t.text :client_address
      t.string :invoice_number
      t.date :invoice_date
      t.date :due_date
      t.text :description
      t.text :rates_and_quantities
      t.decimal :total_amount_due, precision: 10, scale: 2
      t.text :payment_instructions

      t.timestamps
    end

    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :invoice_type
  end
end
