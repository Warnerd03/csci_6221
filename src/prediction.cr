require "./price"
require "time"
require "crystal-ml"

def train_model(points)
  sorted_points = points.sort_by { |p| p[:date] }

  x = (0...sorted_points.size).map { |i| [i.to_f] }
  y = sorted_points.map { |p| p[:price].to_f }

  x_poly = x.map { |row| [row[0], row[0]**2, row[0]**3] }

  model = CrystalML::Regression::LinearRegression.new
  model.fit(x_poly, y)

  {model: model, n_points: sorted_points.size}
end

def predict_next(model_data)
  return nil unless model_data

  model = model_data[:model]
  n_points = model_data[:n_points]

  next_x = n_points.to_f
  next_x_poly = [[next_x, next_x**2, next_x**3]]

  model.predict(next_x_poly)[0]
end

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

retail_model  = train_model(retail_points)
buylist_model = train_model(buylist_points)

retail_pred  = predict_next(retail_model)
buylist_pred = predict_next(buylist_model)

puts "Predicted next retail: #{retail_pred}"
puts "Predicted next buylist: #{buylist_pred}"
