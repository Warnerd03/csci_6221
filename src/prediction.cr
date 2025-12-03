require "json"

file_path = "data/AllPrices.json"
text = File.read(file_path)
data = JSON.parse(text)  # returns JSON::Any

puts data[0].to_pretty_json   # prints the first element nicely
exit
