class AddProjectFieldsToSales < ActiveRecord::Migration[8.0]
  def change
    add_column :sales, :project_name, :string
    add_column :sales, :description, :text
    add_column :sales, :client_name, :string
    add_column :sales, :project_year, :integer
    
    add_index :sales, [:project_year, :project_name], unique: true, where: "project_name IS NOT NULL"
  end
end
