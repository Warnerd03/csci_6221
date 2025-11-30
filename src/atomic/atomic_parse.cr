# src/atomic/atomic_parse.cr
require "json"
require "./atomic"

# Parses the AtomicCards.json files

include MTGAtomic
path = "../data/AtomicCards.json"
number = (ARGV[0]? || "1").to_i

# Check file exists
unless File.exists?(path)
    STDERR.puts "Error: file not found: #{path}"
    exit 1
end

# Get text and parse using structures defined in MTGAtomic
puts "Parsing Atomic cards from \"#{path}\"..."
text = File.read(path)
atomic = AtomicCards.from_json(text)
puts "Parsed #{atomic.data.size} unique card names!"
puts

shown_cards = 0

# Print out the first N cards
puts "Showing the first #{number} cards in the dataset:"
atomic.data.each do |name_key, cards|
    break if shown_cards >= number

    puts "#{name_key}"

    shown_cards += 1
end