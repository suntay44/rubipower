class CreatePurchaseRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_requests do |t|
      t.references :requester_user, null: false, foreign_key: { to_table: :users }
      t.date :request_date
      t.string :priority_level
      t.text :reason_for_purchase
      t.string :sales_order_number
      t.string :client_name
      t.text :additional_notes
      t.boolean :budget_approve, default: false
      t.boolean :procurement_approve, default: false

      t.timestamps
    end
  end
end
