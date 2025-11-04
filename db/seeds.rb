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

# Admin user
admin = User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.first_name = 'Admin'
  user.last_name = 'User'
  user.phone_number = '+1234567890'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.status = 'active'
  user.position = 'Administrator'
  user.department = :general
  user.hire_date = Date.current
end
admin.set_roles(['admin'])

# Finance user
finance_user = User.find_or_create_by!(email: 'finance@example.com') do |user|
  user.first_name = 'Finance'
  user.last_name = 'User'
  user.phone_number = '+1234567891'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.status = 'active'
  user.position = 'Finance Officer'
  user.department = :finance
  user.hire_date = Date.current
end
finance_user.set_roles(['finance'])

# Manager user
manager = User.find_or_create_by!(email: 'manager@example.com') do |user|
  user.first_name = 'Manager'
  user.last_name = 'User'
  user.phone_number = '+1234567892'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.status = 'active'
  user.position = 'Department Manager'
  user.department = :operations
  user.hire_date = Date.current
end
manager.set_roles(['manager'])

# Supervisor user
supervisor = User.find_or_create_by!(email: 'supervisor@example.com') do |user|
  user.first_name = 'Supervisor'
  user.last_name = 'User'
  user.phone_number = '+1234567893'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.status = 'active'
  user.position = 'Team Supervisor'
  user.department = :engineering
  user.hire_date = Date.current
end
supervisor.set_roles(['supervisor'])

# Procurement user
procurement_user = User.find_or_create_by!(email: 'procurement@example.com') do |user|
  user.first_name = 'Procurement'
  user.last_name = 'User'
  user.phone_number = '+1234567894'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.status = 'active'
  user.position = 'Procurement Officer'
  user.department = :operations
  user.hire_date = Date.current
end
procurement_user.set_roles(['procurement'])

# Teammates user
teammate = User.find_or_create_by!(email: 'teammate@example.com') do |user|
  user.first_name = 'Team'
  user.last_name = 'Member'
  user.phone_number = '+1234567895'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.status = 'active'
  user.position = 'Team Member'
  user.department = :general
  user.hire_date = Date.current
end
teammate.set_roles(['teammates'])

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

# Create sample vendors
puts "Creating sample vendors..."

Vendor.create!(
  name: "ABC Electronics Supply Co.",
  address: "123 Main Street, Manila, Philippines",
  tin: "123-456-789-000",
  bank_details: "BDO - Account #: 1234567890\nBranch: Manila Main",
  status: "active"
)

Vendor.create!(
  name: "Global Hardware Solutions",
  address: "456 Commerce Ave, Makati City, Philippines",
  tin: "987-654-321-000",
  bank_details: "BPI - Account #: 9876543210\nBranch: Makati",
  status: "active"
)

Vendor.create!(
  name: "TechPro Equipment Inc.",
  address: "789 Industrial Park, Pasig City, Philippines",
  tin: "555-123-456-000",
  bank_details: "Metrobank - Account #: 5551234567\nBranch: Pasig",
  status: "active"
)

# Assign vendors to existing products
if Product.exists?
  vendors = Vendor.all
  Product.where(vendor_id: nil).find_each do |product|
    product.update!(vendor: vendors.sample)
  end
  puts "Updated existing products with vendors"
end

# Assign vendors to existing materials
if Material.exists?
  vendors = Vendor.all
  Material.where(vendor_id: nil).find_each do |material|
    material.update!(vendor: vendors.sample)
  end
  puts "Updated existing materials with vendors"
end

puts "Creating sample materials..."
# Get random vendors for materials
material_vendors = Vendor.all.to_a

Material.create!(
  name: "Steel Bars",
  description: "High-grade steel reinforcement bars for construction",
  unit: "kg",
  unit_price: 45.50,
  status: "active",
  vendor: material_vendors.sample
)

Material.create!(
  name: "Cement",
  description: "Portland cement for general construction purposes",
  unit: "bag",
  unit_price: 250.00,
  status: "active",
  vendor: material_vendors.sample
)

Material.create!(
  name: "Electrical Wire",
  description: "Copper electrical wire - 2.0mm diameter",
  unit: "meter",
  unit_price: 12.75,
  status: "active",
  vendor: material_vendors.sample
)

puts "Seed data created successfully!"
puts "\nUsers created:"
puts "- Admin: admin@example.com (password: password123)"
puts "- Finance: finance@example.com (password: password123)"
puts "- Manager: manager@example.com (password: password123)"
puts "- Supervisor: supervisor@example.com (password: password123)"
puts "- Procurement: procurement@example.com (password: password123)"
puts "- Teammate: teammate@example.com (password: password123)"
puts "\n- System settings configured"
puts "- Sample reports created"
puts "- Sample vendors created"
puts "- Sample materials created"
