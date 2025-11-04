class AddNameToItemsAndRenameCost < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :name, :string
    rename_column :items, :cost, :quoted_price
  end
end
