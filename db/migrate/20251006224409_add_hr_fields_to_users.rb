class AddHrFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :position, :string
    add_column :users, :department, :string
    add_column :users, :hire_date, :date
    add_column :users, :status, :string
  end
end
