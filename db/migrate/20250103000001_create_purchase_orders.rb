class CreatePurchaseOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :purchase_orders do |t|
      t.references :purchase_request, null: false, foreign_key: true
      t.string :po_number, null: false
      t.string :status, null: false, default: 'draft'
      t.decimal :total_amount, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :purchase_orders, :po_number, unique: true
    add_index :purchase_orders, :status
  end
end
