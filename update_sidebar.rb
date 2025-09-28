#!/usr/bin/env ruby

# Script to remove duplicated sidebar code from all purchase order view files

files_to_update = [
  'app/views/purchase_order/new_purchase_order.html.erb',
  'app/views/purchase_order/new_purchase_request.html.erb',
  'app/views/purchase_order/procurement_review.html.erb'
]

files_to_update.each do |file_path|
  puts "Updating #{file_path}..."
  
  # Read the file
  content = File.read(file_path)
  
  # Remove the closing divs and script
  content = content.gsub(/\s*<\/div>\s*<\/div>\s*<!-- Tooltip for collapsed sidebar -->\s*<div id="tooltip"[^>]*><\/div>\s*<script>[\s\S]*?<\/script>\s*$/, '')
  
  # Write back to file
  File.write(file_path, content)
  
  puts "✓ Updated #{file_path}"
end

puts "\nAll files updated successfully!"
