class CreatePurchaseOrderStatusLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_order_status_logs do |t|
      t.references :purchase_order, null: false, foreign_key: true
      t.string :status
      t.references :updated_by, null: false, foreign_key: { to_table: :users }
      t.text :notes

      t.timestamps
    end
  end
end
