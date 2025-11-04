class MakeCustomerIdOptionalInSales < ActiveRecord::Migration[8.0]
  def change
    # Remove the foreign key constraint first
    remove_foreign_key :sales, :customers if foreign_key_exists?(:sales, :customers)
    
    # Make customer_id nullable
    change_column_null :sales, :customer_id, true
  end
end
