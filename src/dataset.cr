# src/dataset.cr
require "json"

module Dataset
    struct Meta
        include JSON::Serializable

        property date    : String
        property version : String
    end
end