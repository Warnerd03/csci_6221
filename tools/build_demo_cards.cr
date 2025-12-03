require "json"
require "../src/identifier"   # fine to keep
require "../src/dataset"      # fine
require "../src/price"        # fine

module DemoPriceIndex
    struct Meta
        include JSON::Serializable

        property date : String
        property version : String
    end

    struct DatePrice
        include JSON::Serializable

        property date  : String
        property price : Float64
    end

    struct PriceSeries
        include JSON::Serializable

        property uuid     : String
        property format   : String
        property provider : String
        property finish   : String
        property currency : String
        property history  : Array(DatePrice)
    end

    struct PriceIndex
        include JSON::Serializable

        property meta   : Meta
        property series : Array(PriceSeries)
    end
end

# -------------------------------------------------------
# Demo card configuration
# -------------------------------------------------------

DEMO_UUIDS = [
    ["f182e364-0439-5594-a6e6-75f7889ccf45", "/images/ltr-246-the-one-ring.png"],
    ["b0834db4-cd93-5c3d-b776-8e98ecc265b9", "/images/c17-223-sol-ring.jpg"],
    ["7d831656-ff21-5259-ae26-f2e2f06b7e2e", "/images/o90p-2-black-lotus.jpg"],
    ["4e5b927e-0d36-59b0-9fb0-5dcd9b7a8f0e", "/images/mh2-138-ragavan-nimble-pilferer.jpg"],
    ["e1c3fa8d-20a3-5cdb-bb9f-9366388d56b8", "/images/jmp-342-lightning-bolt.jpg"],
]

IDENT_PATH  = File.join(__DIR__, "../data/processed/ident_name_index.json")
PRICE_PATH  = File.join(__DIR__, "../data/processed/price_index.json")
OUTPUT_PATH = File.join(__DIR__, "../data/processed/demo_cards.json")

# -------------------------------------------------------
# Load ident_name_index.json
# -------------------------------------------------------

ident_text = File.read(IDENT_PATH)
raw_ident_index = Hash(String, Array(String)).from_json(ident_text)

# invert name → uuid[] into uuid → name
ident_index = {} of String => String
raw_ident_index.each do |name, uuids|
    uuids.each { |uuid| ident_index[uuid] = name }
end

# -------------------------------------------------------
# Load price_index.json using DemoPriceIndex structs
# -------------------------------------------------------

price_text  = File.read(PRICE_PATH)
price_index = DemoPriceIndex::PriceIndex.from_json(price_text)

# convenience: group series by uuid for faster lookup
series_by_uuid = price_index.series.group_by(&.uuid)

# -------------------------------------------------------
# Build demo card output
# -------------------------------------------------------

output = [] of NamedTuple(
    uuid: String,
    name: String,
    set: String?,
    number: String?,
    image: String,
    predicted_price: Float64 | String,
    recent_price: Float64 | String,
    history_90d: Array(NamedTuple(date: String, price: Float64))
)

DEMO_UUIDS.each do |pair|
    uuid, image_path = pair
    name = ident_index[uuid]?

    unless name
        STDERR.puts "Missing ident for #{uuid}"
        next
    end

    # Pick the best available price series
    possible = series_by_uuid[uuid]? || [] of DemoPriceIndex::PriceSeries

    series =
        possible.find { |s| s.format == "paper" && s.provider == "tcgplayer" && s.finish == "normal" } ||
        possible.find { |s| s.format == "paper" } ||
        possible.first?

    history_90d = [] of NamedTuple(date: String, price: Float64)
    recent      = "N/A"
    predicted   = "N/A"

    if series
        last_90 = series.history.last(90)
        last_90.each do |dp|
            history_90d << {date: dp.date, price: dp.price}
        end

        if v = history_90d.last?
            recent = v[:price]
            predicted = recent.is_a?(Float64) ? (recent * 1.03) : "N/A"
        end
    end

    output << {
        uuid: uuid,
        name: name,
        set: nil,
        number: nil,
        image: image_path,
        predicted_price: predicted,
        recent_price: recent,
        history_90d: history_90d,
    }
end

File.write(OUTPUT_PATH, output.to_json)
puts "Wrote #{output.size} demo cards → #{OUTPUT_PATH}"
