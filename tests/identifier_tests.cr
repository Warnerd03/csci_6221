# tests/identifier_demo.cr
require "../src/identifier"

MTGIdentifier::DB.load

# puts "Meta date:    #{MTGIdentifier::DB.all.meta.date}"
# puts "Meta version: #{MTGIdentifier::DB.all.meta.version}"

# 1) First entry
uuid, ident = MTGIdentifier::DB.all.data.first
puts
puts "First UUID: #{uuid}"
puts "Name:       #{ident.name}"

# 2) Look up by UUID
puts
puts "Lookup by UUID:"
found = MTGIdentifier::DB.find_uuid(uuid)
puts found ? "Found: #{found.name}" : "Not found"

# 3) All UUIDs for a card name
puts
name = ident.name
puts "All UUIDs for name '#{name}':"
MTGIdentifier::DB.uuids_for_name(name).each do |u|
    puts "- #{u}"
end

# 4) Fuzzy search
puts
puts "Search names containing 'Sphinx':"
[""]
MTGIdentifier::DB.search_names("Sphinx").first(5).each do |u, info|
    puts "- #{u} | #{info.name}"
end
