# src/identifier.cr
require "json"
require "./dataset"

module MTGIdentifier
    # Meta information about the identifier data
    alias Meta = Dataset::Meta

    # Represents an individual identifier entry
    struct Identifier
        include JSON::Serializable

        property name : String
    end

    # The root structure for AllIdentifiers.json
    struct AllIdentifiers
        include JSON::Serializable

        property meta : Meta
        property data : Hash(String, Identifier)
    end

    # Database module for loading and querying identifier data
    module DB
        # Path constants
        FULL_PATH = File.join(__DIR__, "../data/raw/AllIdentifiers.json")
        INDEX_PATH = File.join(__DIR__, "../data/processed/ident_name_index.json")

        # Class variables
        @@all : AllIdentifiers?
        @@by_name : Hash(String, Array(String))?

        # Getters
        def self.all : AllIdentifiers
            if all = @@all
                all
            else
                unless File.exists?(FULL_PATH)
                    raise "AllIdentifiers.json not found at #{FULL_PATH}"
                end
                text = File.read(FULL_PATH)
                @@all = AllIdentifiers.from_json(text)
            end
        end

        def self.by_name_index : Hash(String, Array(String))
            @@by_name || raise "MTGIdentifier::DB not loaded. Call MTGIdentifier::DB.load first."
        end

        def self.meta : Meta
            all.meta
        end

        # Iterator
        def self.each(&block : String, Identifier ->)
            all.data.each do |uuid, ident|
                yield uuid, ident
            end
        end

        # Load AllIdentifiers.json data and build a name Hash index structure
        def self.load(path : String? = nil)
            # Check if precompiled index exists
            if File.exists?(INDEX_PATH)
                # Fast path
                text = File.read(INDEX_PATH)
                @@by_name = Hash(String, Array(String)).from_json(text)
            else
                # Slow path
                unless File.exists?(FULL_PATH)
                    raise "AllIdentifiersjson not found at #{FULL_PATH}"
                end

                # Parse JSON and store in class variable
                text = File.read(FULL_PATH)
                all = AllIdentifiers.from_json(text)
                @@all = all

                # Create name index
                name_index = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }
                all.data.each do |uuid, ident|
                    name_index[ident.name] << uuid
                end
                @@by_name = name_index

                File.write(INDEX_PATH, name_index.to_json)
            end
        end

        # === Lookups ====

        # Exact UUID -> Identifier?
        def self.find_uuid(uuid : String) : Identifier?
            all.data[uuid]?
        end

        # Exact name → [uuid, uuid, ...]
        def self.uuids_for_name(name : String) : Array(String)
            by_name_index[name]? || [] of String
        end

        # (uuid, Identifier) pairs for all printings of this name
        def self.printings_for_name(name : String) : Array({String, Identifier})
            uuids_for_name(name).map do |uuid|
                { uuid, all.data[uuid] }
            end
        end

        # Case-insensitive substring search on names
        def self.search_names(substr : String) : Array({String, Identifier})
            search = substr.downcase
            res = [] of {String, Identifier}

            all.data.each do |uuid, ident|
                if ident.name.downcase.includes?(search)
                    res << {uuid, ident}
                end
            end

            res
        end
    end
end