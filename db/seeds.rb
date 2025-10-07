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

puts "Seed data created successfully!"
puts "- Admin user: admin@example.com (password: password123)"
puts "- Staff user: staff@example.com (password: password123)"
puts "- Regular user: user@example.com (password: password123)"
