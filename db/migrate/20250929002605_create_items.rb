class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.references :purchase_request, null: false, foreign_key: true
      t.text :description
      t.integer :quantity
      t.decimal :cost, precision: 10, scale: 2

      t.timestamps
    end
  end
end
