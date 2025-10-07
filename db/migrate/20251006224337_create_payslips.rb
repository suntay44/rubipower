class CreatePayslips < ActiveRecord::Migration[8.0]
  def change
    create_table :payslips do |t|
      t.references :user, null: false, foreign_key: true
      t.date :pay_period_start
      t.date :pay_period_end
      t.decimal :gross_pay
      t.decimal :deductions
      t.decimal :net_pay
      t.string :status

      t.timestamps
    end
  end
end
