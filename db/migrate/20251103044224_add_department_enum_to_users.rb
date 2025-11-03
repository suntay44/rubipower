class AddDepartmentEnumToUsers < ActiveRecord::Migration[8.0]
  def up
    # First, update existing department values to match new enum
    execute <<-SQL
      UPDATE users 
      SET department = CASE department
        WHEN 'Finance' THEN '0'
        WHEN 'Engineering' THEN '1'
        WHEN 'Operations' THEN '2'
        WHEN 'General' THEN '3'
        ELSE '3'
      END
      WHERE department IS NOT NULL;
    SQL

    # Change column type to integer
    change_column :users, :department, 'integer USING department::integer', default: nil
  end

  def down
    # Reverse the migration
    change_column :users, :department, :string

    # Convert back to string values
    execute <<-SQL
      UPDATE users 
      SET department = CASE department
        WHEN '0' THEN 'Finance'
        WHEN '1' THEN 'Engineering'
        WHEN '2' THEN 'Operations'
        WHEN '3' THEN 'General'
        ELSE NULL
      END
      WHERE department IS NOT NULL;
    SQL
  end
end
