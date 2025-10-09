class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.string :name
      t.string :report_type
      t.string :date_range
      t.string :status
      t.datetime :generated_at

      t.timestamps
    end
  end
end
