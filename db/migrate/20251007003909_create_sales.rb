class CreateSales < ActiveRecord::Migration[8.0]
  def change
    create_table :sales do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :sale_number, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.string :payment_method
      t.string :payment_status, default: 'pending'
      t.datetime :sale_date, null: false
      t.text :notes

      t.timestamps
    end

    add_index :sales, :sale_number, unique: true
    add_index :sales, :payment_status
    add_index :sales, :sale_date
  end
end
