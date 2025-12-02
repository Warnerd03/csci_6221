# parsing.cr
require "json"
require "./mtg_prices/models"
require "./load_atomic"

include MTGPrices

# 1. Choose file: CLI arg or default AllPricesToday.json
json_path = ARGV[0]? || "data/AllPricesToday.json"

unless File.exists?(json_path)
  STDERR.puts "Error: file not found: #{json_path}"
  exit 1
end

# 2. Parse into AllPrices (paper-only PriceFormats)
json_text  = File.read(json_path)
all_prices = AllPrices.from_json(json_text)

puts "Meta date: #{all_prices.meta.date}"
puts "Version:   #{all_prices.meta.version}"
puts "Cards:     #{all_prices.data.size}"
puts


uuid_to_name = build_uuid_index("data/AtomicCards.json")

uuid, formats = all_prices.data.first
card_name = uuid_to_name[uuid] || "Unknown Card"

puts "First paper UUID: #{uuid}"
puts "Card name:        #{card_name}"
puts

# 4. Pretty-print JUST the paper part as JSON
paper_only = formats.paper.not_nil!

pretty = String.build do |io|
  JSON.build(io, indent: 2) do |builder|
    paper_only.to_json(builder)
  end
end

puts pretty
