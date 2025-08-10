class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :roles, :user_id
    add_index :roles, :name
    add_index :roles, [ :user_id, :name ], unique: true
    add_foreign_key :roles, :users, on_delete: :cascade
  end
end
