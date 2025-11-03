class CreateVendors < ActiveRecord::Migration[8.0]
  def change
    create_table :vendors do |t|
      t.string :name, null: false
      t.text :address
      t.string :tin
      t.text :bank_details
      t.string :status, default: "active"

      t.timestamps
    end

    add_index :vendors, :name
    add_index :vendors, :tin
    add_index :vendors, :status
  end
end
