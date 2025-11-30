require "yaml"
require "./model"

module MTGPrices
    struct CardPrice
        include YAML::Serializable

        property UUID           : String
        property paper_currency : String?

        property normal_retail  : Hash(String, Float64)?
        property foil_retail    : Hash(String, Float64)?
        property normal_buy     : Hash(String, Float64)?
        property foil_buy       : Hash(String, Float64)?
    end

    struct Stats
        include YAML::Serializable

        property total_cards      : Int32
        property provider_counts  : Hash(String, Int32)
        property currency_counts  : Hash(String, Int32)
        property normal_min_price : Float64?
        property normal_max_price : Float64?
        property normal_avg_price : Float64?
        property normal_histogram : Hash(String, Int32)

        def initialize(
            @total_cards : Int32 ,
            @provider_counts : Hash(String, Int32),
            @currency_counts : Hash(String, Int32),
            @normal_min_price : Float64?,
            @normal_max_price : Float64?,
            @normal_avg_price : Float64?,
            @normal_histogram : Hash(String, Int32)
        )
        end

        def pretty_print(io = STDOUT)
            io.puts "=== Price Stats ==="
            io.puts "Total cards in cache: #{total_cards}"

            io.puts "\nProviders:"
            provider_counts.each do |name, count|
                io.puts "  #{name}: #{count}"
            end

            io.puts "\nCurrencies:"
            currency_counts.each do |currency, count|
                io.puts "  #{currency}: #{count}"
            end

            io.puts "\nNormal retail price summary:"
            io.puts "  min: #{normal_min_price || "n/a"}"
            io.puts "  max: #{normal_max_price || "n/a"}"
            io.puts "  avg: #{normal_avg_price || "n/a"}"

            io.puts "\nNormal retail histogram:"
            normal_histogram.each do |bucket, count|
                io.puts "  #{bucket}: #{count}"
            end
        end
    end

    class Store
        include YAML::Serializable

        property generated_at : Time
        property cards        : Hash(String, CardPrice)
        property stats        : Stats

        def initialize(
            @generated_at : Time,
            @cards        : Hash(String, CardPrice),
            @stats        : Stats
        )
        end

        def [](uuid : String) : CardPrice? 
            @cards[uuid]?
        end

        def latest_normal_price(uuid : String) : Float64?
            card = cards[uuid]?
            return nil unless card
            dates = card.normal_retail.try &.keys
            return nil unless dates && !dates.empty?
            latest_date = dates.max
            card.normal_retail.try &.[latest_date]
        end
    end