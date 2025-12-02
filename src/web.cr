# src/web.cr
require "kemal"

get "/" do
    "Welcome to the MTG Project!"
end

get "/api/ping" do
    { status: "ok", message: "pong" }.to_json
end

Kemal.run