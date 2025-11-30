# src/atomic.cr
require "json"

# This module provides the interface and parsing formats for MTG Atomic card data.
# https://mtgjson.com/data-models/card/card-atomic/

module MTGAtomic
    
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

    # The root structure for AtomicCards.json
    struct AtomicCards
        include JSON::Serializable

        property meta : Meta
        property data : Hash(String, Array(CardAtomic))

        # Returns the number of unique card names in the dataset
        def count_names : Int32
            return data.size
        end
    end

    module DB
        @@atomic : AtomicCards?

        def self.load(path : String? = nil)
            json_path = path || File.join(__DIR__, "../data/AtomicCards.json")

            unless File.exists?(json_path)
                raise "AtomicCards.json not found at #{json_path}"
            end

            text = File.read(json_path)
            @@atomic = AtomicCards.from_json(text)
        end

        def self.atomic : AtomicCards
            @@atomic || raise "MTGAtomic::DB not loaded. Call MTGAtomic::DB.load first."
        end



        def self.each_card(&block : String, CardAtomic ->)
            atomic.data.each do |name_key, cards|
                cards.each do |card|
                    yield(name_key, card)
                end
            end
        end

        # Prints statistics about the loaded Atomic dataset
        def self.print_stats(io = STDOUT)
            a = atomic
            io.puts "=== MTG Atomic Stats ==="
            io.puts "Date:           #{a.meta.date}"
            io.puts "Version:        #{a.meta.version}"
            io.puts "Distinct names: #{a.count_names}"
        end
    end
end