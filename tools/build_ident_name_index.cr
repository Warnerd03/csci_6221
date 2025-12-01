# tools/build_ident_name_index.cr
require "json"
require "../src/dataset"
require "../src/identifier"

include MTGIdentifier

# Load full AllIdentifiers dataset
full_path = File.join(__DIR__, "../data/AllIdentifiers.json")
index_path = File.join(__DIR__, "../data/ident_name_index.json")

include MTGIdentifier

text = File.read(full_path)
all  = AllIdentifiers.from_json(text)

name_index = Hash(String, Array(String)).new { |h, k| h[k] = [] of String } 

all.data.each do |uuid, ident|
    name_index[ident.name] << uuid
end

File.write(index_path, name_index.to_json)

puts "Wrote name index with #{name_index.size} names to #{index_path}"