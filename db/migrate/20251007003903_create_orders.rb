class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :order_number, null: false
      t.string :status, default: 'pending'
      t.string :priority, default: 'medium'
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.datetime :order_date, null: false
      t.text :shipping_address
      t.string :payment_method
      t.string :payment_status, default: 'pending'

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, :status
    add_index :orders, :priority
    add_index :orders, :order_date
  end
end
