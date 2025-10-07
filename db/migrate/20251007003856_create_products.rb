class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.text :description
      t.string :category
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock_quantity, default: 0
      t.integer :reorder_level, default: 10
      t.string :status, default: 'active'

      t.timestamps
    end

    add_index :products, :sku, unique: true
    add_index :products, :category
    add_index :products, :status
  end
end
