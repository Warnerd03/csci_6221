# src/price.cr
require "json"
require "./dataset"

module MTGPrice
    alias Meta = Dataset::Meta

    struct PricePoint
        include JSON::Serializable
        
        property etched : Hash(String, Float32)?
        property foil   : Hash(String, Float32)?
        property normal : Hash(String, Float32)?
    end

    struct PriceList
        include JSON::Serializable

        property buylist  : PricePoint?
        property currency : String
        property retail   : PricePoint?
    end

    struct PriceFormats
        include JSON::Serializable

        property paper : Hash(String, PriceList)? # 'cardkingdom', 'cardmarket', 'cardsphere', 'tcgplayer'
        property mtgo  : Hash(String, PriceList)?
    end

    struct AllPrices
        include JSON::Serializable

        property meta : Meta
        property data : Hash(String, PriceFormats)
    end

    module DB
        FULL_PATH = File.join(__DIR__, "../data/raw/AllPrices.json")
        
        @@all : AllPrices?
        @@all_today : AllPrices?
        
        def self.all : AllPrices
            if all = @@all
                all
            else
                unless File.exists?(FULL_PATH)
                    raise "AllPricesToday.json not found at #{FULL_PATH}"
                end
                text = File.read(FULL_PATH)
                @@all = AllPrices.from_json(text)
            end
        end
    end
end

# include MTGPrice
# file_path = File.join(__DIR__, "../data/raw/AllPricesToday.json")

# text = File.read(file_path)
# all_prices = AllPrices.from_json(text)
# puts "Loaded #{all_prices.data.size} price entries."

# uuid, formats = all_prices.data.first
# puts "First UUID: #{uuid}"
# puts "Price formats available: #{formats.paper.to_s}, #{formats.mtgo.to_s}"
