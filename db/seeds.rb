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
end
admin.set_roles([ 'admin' ])

# Staff user (has staff role)
staff = User.find_or_create_by!(email: 'staff@example.com') do |user|
  user.first_name = 'Staff'
  user.last_name = 'User'
  user.phone_number = '+1234567891'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end
staff.set_roles([ 'staff' ])

# Approver user (has approver role)
approver = User.find_or_create_by!(email: 'approver@example.com') do |user|
  user.first_name = 'Approver'
  user.last_name = 'User'
  user.phone_number = '+1234567893'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end
approver.set_roles([ 'approver' ])

# Staff + Approver user (has multiple roles)
staff_approver = User.find_or_create_by!(email: 'staff_approver@example.com') do |user|
  user.first_name = 'Staff'
  user.last_name = 'Approver'
  user.phone_number = '+1234567894'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end
staff_approver.set_roles([ 'staff', 'approver' ])

# Regular user (has user role)
regular_user = User.find_or_create_by!(email: 'user@example.com') do |user|
  user.first_name = 'Regular'
  user.last_name = 'User'
  user.phone_number = '+1234567892'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end
regular_user.set_roles([ 'user' ])

puts "Seed users created successfully!"
puts "Admin: #{admin.email} / password123 (roles: #{admin.role_names.join(', ')})"
puts "Staff: #{staff.email} / password123 (roles: #{staff.role_names.join(', ')})"
puts "Approver: #{approver.email} / password123 (roles: #{approver.role_names.join(', ')})"
puts "Staff+Approver: #{staff_approver.email} / password123 (roles: #{staff_approver.role_names.join(', ')})"
puts "User: #{regular_user.email} / password123 (roles: #{regular_user.role_names.join(', ')})"
