class AddDeliveryFieldsToPurchaseOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :purchase_orders, :delivery_note, :text
  end
end
