# src/web.cr
require "kemal"
require "ecr"

get "/" do
    ECR.render("views/index.ecr")
end

get "/api/ping" do
    { status: "ok", message: "pong" }.to_json
end

Kemal.run