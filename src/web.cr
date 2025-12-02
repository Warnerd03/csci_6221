require "kemal"
require "ecr"

# Simple in-memory demo card data
DEMO_CARDS = {
  "demo-the-one-ring" => {
    name: "The One Ring",
    set_line: "Tales of Middle-earth (LTR) · #246 · Mythic Rare",
    image_path: "/images/ltr-246-the-one-ring.png",
    predicted_price: "$72.34",
    recent_price: "$68.50",
    history_range: "Last 30 days",
    demo_points: {
      "30 days ago" => "$63.20",
      "21 days ago" => "$65.75",
      "14 days ago" => "$69.10",
      "7 days ago"  => "$70.90",
      "Today"       => "$72.34",
    },
  },
  "demo-sol-ring" => {
    name: "Sol Ring",
    set_line: "Various sets · Commander staple",
    image_path: "/images/ltr-246-the-one-ring.png", # placeholder image
    predicted_price: "$3.15",
    recent_price: "$2.90",
    history_range: "Last 90 days",
    demo_points: {
      "90 days ago" => "$2.40",
      "60 days ago" => "$2.55",
      "30 days ago" => "$2.80",
      "7 days ago"  => "$3.00",
      "Today"       => "$3.15",
    },
  },
  "demo-black-lotus" => {
    name: "Black Lotus",
    set_line: "Alpha · Reserved List",
    image_path: "/images/ltr-246-the-one-ring.png", # placeholder image
    predicted_price: "$25,000.00",
    recent_price: "$24,200.00",
    history_range: "Last 365 days",
    demo_points: {
      "1 year ago"  => "$20,000.00",
      "9 months ago"=> "$21,500.00",
      "6 months ago"=> "$22,800.00",
      "3 months ago"=> "$23,500.00",
      "Today"       => "$25,000.00",
    },
  },
  "demo-ragavan" => {
    name: "Ragavan, Nimble Pilferer",
    set_line: "Modern Horizons 2",
    image_path: "/images/ltr-246-the-one-ring.png", # placeholder image
    predicted_price: "$58.90",
    recent_price: "$55.00",
    history_range: "Last 60 days",
    demo_points: {
      "60 days ago" => "$48.00",
      "45 days ago" => "$50.50",
      "30 days ago" => "$52.75",
      "7 days ago"  => "$56.20",
      "Today"       => "$58.90",
    },
  },
}

get "/" do
    ECR.render("views/index.ecr")
end

# Card detail pages
get "/card/:id" do |env|
    id = env.params.url["id"]
    data = DEMO_CARDS[id]?

    halt env, status_code: 404, response: "Card not found" unless data

    card_name       = data[:name]
    set_line        = data[:set_line]
    image_path      = data[:image_path]
    predicted_price = data[:predicted_price]
    recent_price    = data[:recent_price]
    history_range   = data[:history_range]
    demo_points     = data[:demo_points]

    ECR.render("views/card.ecr")
end

# Search results page (very simple demo matching by name substring)
get "/search" do |env|
    query = env.params.query["q"]?.to_s.strip
    q_down = query.downcase

    matched_cards = DEMO_CARDS.map do |id, data|
        name = data[:name]
        if q_down.empty? || name.downcase.includes?(q_down)
        {
            path: "/card/#{id}",
            name: name,
            set_line: data[:set_line],
            predicted_price: data[:predicted_price],
        }
        else
            nil
        end
    end.compact

    ECR.render("views/search.ecr")
end

get "/about" do
    ECR.render("views/about.ecr")
end

Kemal.run
