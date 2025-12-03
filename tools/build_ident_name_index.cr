# tools/build_ident_name_index.cr
require "json"
require "../src/dataset"
require "../src/price"
require "../src/identifier"

include MTGIdentifier

# Load full AllIdentifiers dataset
input_path = ARGV[0]? || File.join(__DIR__, "../data/raw/AllIdentifiers.json")
output_path = ARGV[1]? || File.join(__DIR__, "../data/processed/ident_name_index.json")

unless File.exists?(input_path)
    raise "AllIdentifiers.json not found at #{input_path}"
end

text = File.read(input_path)
all  = AllIdentifiers.from_json(text)

index = Hash(String, Array(String)).new { |h, k| h[k] = [] of String } 

all.data.each do |uuid, ident|
    index[ident.name] << uuid
end

File.open(output_path, "w") do |file|
    JSON.build(file, indent: 2) do |builder|
        index.to_json(builder)
    end
end

puts "Wrote name index with #{index.size} names to #{output_path}"