# src/identifier.cr
require "json"
require "./dataset"

module MTGIdentifier
    alias Meta = Dataset::Meta

    struct Identifier
        include JSON::Serializable

        property name : String
    end

    struct AllIdentifiers
        include JSON::Serializable

        property meta : Meta
        property data : Hash(String, Identifier)
    end
end

include MTGIdentifier

# Example usage
json_path = "../data/AllIdentifiers.json"
text = File.read(json_path)
identifiers = AllIdentifiers.from_json(text)

puts identifiers.data.first