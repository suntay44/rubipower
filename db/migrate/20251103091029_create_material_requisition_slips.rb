class CreateMaterialRequisitionSlips < ActiveRecord::Migration[8.0]
  def change
    create_table :material_requisition_slips do |t|
      t.references :requester_user, null: false, foreign_key: { to_table: :users }
      t.string :department
      t.date :request_date, null: false
      t.text :purpose
      t.string :priority_level, default: "medium"
      t.string :status, default: "pending"
      t.integer :approved_by
      t.datetime :approved_at

      t.timestamps
    end
    
    add_index :material_requisition_slips, :status
    add_index :material_requisition_slips, :request_date
  end
end
