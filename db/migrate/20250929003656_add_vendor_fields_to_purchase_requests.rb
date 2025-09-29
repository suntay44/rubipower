class AddVendorFieldsToPurchaseRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :purchase_requests, :vendor_name, :string
    add_column :purchase_requests, :vendor_address, :text
    add_column :purchase_requests, :bank_details, :text
  end
end
