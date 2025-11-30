# src/mtg_atomic.cr
require "json"

# This module provides the interface and parsing formats for MTG Atomic card data.
# https://mtgjson.com/data-models/card/card-atomic/

module MTGAtomic
    # The root structure for AtomicCards.json
    struct AtomicCards
        include JSON::Serializable

        property meta : Meta
        property data : Hash(String, Array(CardAtomic))
    end

    # Meta information about the Atomic card data
    struct Meta
        include JSON::Serializable

        property date    : String
        property version : String
    end

    # Represents an individual card in the Atomic dataset
    struct CardAtomic
        include JSON::Serializable

        property name          : String
        property colorIdentity : Array(String)
    end
end