# tools/build_price_index.cr
require "json"
require "../src/dataset"
require "../src/price"

include MTGPrice

module MTGPriceIndex
    alias Meta = Dataset::Meta

    struct DatePrice
        include JSON::Serializable

        property date : String
        property price : Float32

        def initialize(@date : String, @price : Float32)
        end
    end

    struct PriceSeries
        include JSON::Serializable

        property uuid     : String
        property format   : String
        property provider : String
        property finish   : String
        property currency : String
        property history  : Array(DatePrice)

        def initialize(@uuid : String, @format : String, @provider : String, @finish : String, @currency : String, @history : Array(DatePrice))
        end
    end

    struct PriceIndex
        include JSON::Serializable

        property meta   : Meta
        property series : Array(PriceSeries)

        def initialize(@meta : Meta, @series : Array(PriceSeries))
        end
    end

    def self.build_from(all : MTGPrice::AllPrices) : PriceIndex
        result = [] of PriceSeries

        all.data.each do |uuid, formats|
            {
                "paper" => formats.paper,
                "mtgo"  => formats.mtgo
            }.each do |format_name, providers|
                next unless providers
                providers.each do |provider_name, plist|
                    {
                        "buylist" => plist.buylist,
                        "retail"  => plist.retail,
                    }.each do |kind_name, points|
                        next unless points
                        {
                            "normal" => points.normal,
                            "foil"   => points.foil,
                            "etched" => points.etched,
                        }.each do |finish_name, date_map|
                            next unless date_map
                            history = date_map.map do |date, price|
                                DatePrice.new(date, price)
                            end
                            history.sort_by!(&.date)
                            next if history.empty?

                            result << PriceSeries.new(
                                uuid: uuid,
                                format: format_name,
                                provider: provider_name,
                                finish: finish_name,
                                currency: plist.currency,
                                history: history,
                            )
                        end
                    end
                end
            end
        end

        PriceIndex.new(meta: all.meta, series: result)
    end
end

input_path = ARGV[0]? || File.join(__DIR__, "../data/raw/AllPricesToday.json")
output_path = ARGV[1]? || File.join(__DIR__, "../data/processed/price_index.json")

unless File.exists?(input_path)
    STDERR.puts "Error: input file not found: #{input_path}"
    exit 1
end

text = File.read(input_path)
all = MTGPrice::AllPrices.from_json(text)

index = MTGPriceIndex.build_from(all)

File.open(output_path, "w") do |file|
    JSON.build(file, indent: 2) do |builder|
        index.to_json(builder)
    end
end

puts "Wrote price index with #{index.series.size} series to #{output_path}"