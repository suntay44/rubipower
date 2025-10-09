class AddGeolocationToAttendances < ActiveRecord::Migration[8.0]
  def change
    add_column :attendances, :clock_in_latitude, :decimal, precision: 10, scale: 6
    add_column :attendances, :clock_in_longitude, :decimal, precision: 10, scale: 6
    add_column :attendances, :clock_in_accuracy_m, :decimal, precision: 10, scale: 2

    add_column :attendances, :clock_out_latitude, :decimal, precision: 10, scale: 6
    add_column :attendances, :clock_out_longitude, :decimal, precision: 10, scale: 6
    add_column :attendances, :clock_out_accuracy_m, :decimal, precision: 10, scale: 2

    add_column :attendances, :ip_address, :string
  end
end
