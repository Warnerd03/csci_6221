# models.cr
require "json"

module MTGPrices
    struct PricePoints
        include JSON::Serializable
        property etched : Hash(String, Float64)?
        property foil   : Hash(String, Float64)?
        property normal : Hash(String, Float64)?
    end

    struct PriceList
        include JSON::Serializable
        property buylist  : PricePoints?
        property currency : String
        property retail   : PricePoints?
    end

    struct PriceFormats
        include JSON::Serializable
        property paper : Hash(String, PriceList)?
    end

    struct Meta
        include JSON::Serializable
        property date    : String
        property version : String
    end

    # This root works for *both* AllPrices.json and AllPricesToday.json
    struct AllPrices
        include JSON::Serializable
        property meta : Meta
        property data : Hash(String, PriceFormats)
    end
end
