require "json"
require "./price"
require "time"
require "crystal-ml"

include MTGPrice

# -------------------------------
# Load prices
# -------------------------------
# all_prices = MTGPrice::DB.all
# f182e364-0439-5594-a6e6-75f7889ccf45

# -------------------------------
# User input
# -------------------------------
# print "\nCard UUID:\n"
# uuid = "f182e364-0439-5594-a6e6-75f7889ccf45"

# print "Vendor/store (e.g., tcgplayer, cardkingdom):\n"
# vendor = "tcgplayer"

# print "Card type (normal/foil/etched):\n"
# ctype = "normal"

# -------------------------------
# Extract data
# -------------------------------
# formats = all_prices.data[uuid]
# print formats
# unless formats
#   puts "UUID not found"
#   exit
# end

# plist = nil

# if formats.paper
#   plist = formats.paper[vendor]  # safe because formats.paper is not nil
# elsif formats.mtgo
#   plist = formats.mtgo[vendor]
# end

# unless plist
#   puts "No price data for this card/vendor combination"
#   exit
# end


# unless plist
#   puts "No price data for this card on vendor #{vendor}"
#   exit
# end



# Collect points for retail and buylist
def collect_points(price_point : PricePoint?, ctype : String)
  return [] of NamedTuple(date: String, price: Float32) unless price_point

  prices = case ctype.downcase
           when "normal" then price_point.normal
           when "foil"   then price_point.foil
           when "etched" then price_point.etched
           else nil
           end

  return [] of NamedTuple(date: String, price: Float32) unless prices

  prices.map { |date, price| {date: date, price: price} }.sort_by { |p| p[:date] }

end

# Sample points: date index (0..5) and price following a quadratic trend
retail_points = [
  {date: "day0", price: 1.0},
  {date: "day1", price: 4.2},
  {date: "day2", price: 5.8},
  {date: "day3", price: 6.6},
  {date: "day4", price: 7.0},
  {date: "day5", price: 7.2},
]

buylist_points = [
  {date: "day0", price: 1.0},
  {date: "day1", price: 1.2},
  {date: "day2", price: 1.6},
  {date: "day3", price: 2.4},
  {date: "day4", price: 4.0},
  {date: "day5", price: 7.2},
]

# retail_points  = collect_points(plist.retail, ctype)
# buylist_points = collect_points(plist.buylist, ctype)

if retail_points.empty? && buylist_points.empty?
  puts "No price data for this card type"
  exit
end

# -------------------------------
# Train polynomial regression (degree 3)
# -------------------------------
def train_model(points)
  return nil if points.size < 5

  # Sort points by date string (lexicographic sort works for YYYY-MM-DD)
  sorted_points = points.sort_by { |p| p[:date] }

  # X = index of each point as 2D array, Y = prices
  x = (0...sorted_points.size).map { |i| [i.to_f] }  # [[0.0], [1.0], ...]
  y = sorted_points.map { |p| p[:price].to_f }

  # Use Crystal-ML linear regression with polynomial features
  # Generate polynomial features manually (degree 3)
  x_poly = x.map { |row| [row[0], row[0]**2, row[0]**3] }

  model = CrystalML::Regression::LinearRegression.new
  model.fit(x_poly, y)

  {model: model, n_points: sorted_points.size}
end

# -------------------------------
# Predict next day
# -------------------------------
def predict_next(model_data)
  return nil unless model_data

  model = model_data[:model]
  n_points = model_data[:n_points]

  # Next index
  next_x = n_points.to_f
  next_x_poly = [[next_x, next_x**2, next_x**3]]

  model.predict(next_x_poly)[0]
end



retail_model  = train_model(retail_points)
buylist_model = train_model(buylist_points)

retail_pred  = predict_next(retail_model)
buylist_pred = predict_next(buylist_model)

puts "Predicted next retail: #{retail_pred}"
puts "Predicted next buylist: #{buylist_pred}"
