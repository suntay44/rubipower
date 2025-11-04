class CreateMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :materials do |t|
      t.string :name, null: false
      t.text :description
      t.string :unit
      t.decimal :unit_price, precision: 10, scale: 2
      t.string :status, default: "active"

      t.timestamps
    end
    
    add_index :materials, :name
    add_index :materials, :status
  end
end
