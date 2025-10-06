class CreateExpenseReports < ActiveRecord::Migration[8.0]
  def change
    create_table :expense_reports do |t|
      t.references :cash_advance_request, null: false, foreign_key: true
      t.text :explanation
      t.integer :unused_cash, default: 0
      t.references :submitted_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
