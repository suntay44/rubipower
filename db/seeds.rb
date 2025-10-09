# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create initial users for testing
puts "Creating seed users..."

# Admin user (has admin role)
admin = User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.first_name = 'Admin'
  user.last_name = 'User'
  user.phone_number = '+1234567890'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.status = 'active'
end
admin.set_roles([ 'admin' ])

# Staff user (has staff role)
staff = User.find_or_create_by!(email: 'staff@example.com') do |user|
  user.first_name = 'Staff'
  user.last_name = 'User'
  user.phone_number = '+1234567891'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.status = 'active'
  user.position = 'Staff Member'
  user.department = 'Operations'
  user.hire_date = Date.current
end
staff.set_roles([ 'staff' ])

# Regular user (has user role)
regular_user = User.find_or_create_by!(email: 'user@example.com') do |user|
  user.first_name = 'Regular'
  user.last_name = 'User'
  user.phone_number = '+1234567892'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.status = 'active'
  user.position = 'Employee'
  user.department = 'General'
  user.hire_date = Date.current
end
regular_user.set_roles([ 'user' ])

# Create system settings
puts "Creating system settings..."

SystemSetting.set("annual_leave_days", "15", "Default annual leave days per year")
SystemSetting.set("sick_leave_days", "10", "Default sick leave days per year")
SystemSetting.set("personal_leave_days", "5", "Default personal leave days per year")
SystemSetting.set("default_conversion_rate", "3.2", "Default conversion rate percentage")

# Create sample reports
puts "Creating sample reports..."

Report.create!(
  name: "Monthly Sales Report",
  report_type: "Sales",
  date_range: "Dec 1 - Dec 31, 2024",
  status: "ready",
  generated_at: 2.hours.ago
)

Report.create!(
  name: "Inventory Analysis",
  report_type: "Inventory",
  date_range: "Dec 1 - Dec 31, 2024",
  status: "ready",
  generated_at: 1.day.ago
)

Report.create!(
  name: "Customer Insights",
  report_type: "Customer",
  date_range: "Nov 1 - Nov 30, 2024",
  status: "processing",
  generated_at: 3.days.ago
)

puts "Seed data created successfully!"
puts "- Admin user: admin@example.com (password: password123)"
puts "- Staff user: staff@example.com (password: password123)"
puts "- Regular user: user@example.com (password: password123)"
puts "- System settings configured"
