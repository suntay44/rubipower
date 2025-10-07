class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.text :address
      t.string :customer_type, default: 'individual'
      t.string :status, default: 'active'
      t.integer :total_orders, default: 0
      t.decimal :total_spent, precision: 10, scale: 2, default: 0
      t.datetime :last_order_date

      t.timestamps
    end

    add_index :customers, :email, unique: true
    add_index :customers, :customer_type
    add_index :customers, :status
  end
end
