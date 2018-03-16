require "kemal"
require "faker"
require "crest"

class Data
  class_property users
  class_property versions

  @@versions = ""
  @@users = {} of Int32 => Hash(String, String)
end

def update_versions
  response =
    Crest.get("https://api.github.com/repos/gdotdesign/elm-ui/releases")

  Data.versions = response.body
end

def generate_users
  Faker.seed 10

  Array.new(100) do |id|
    Data.users[id] = {
      "status"     => Faker.rng.rand(2) > 0 ? "active" : "locked",
      "first_name" => Faker::Name.first_name,
      "last_name"  => Faker::Name.last_name,
      "updated_at" => Time.now.to_s,
      "created_at" => Time.now.to_s,
      "id"         => id.to_s,
    }
  end
end

before_all do |env|
  env.response.content_type = "application/json"
  env.response.headers["Access-Control-Allow-Origin"] = "*"

  env.response.headers["Access-Control-Allow-Methods"] =
    "GET,PUT,POST,DELETE,OPTIONS"

  env.response.headers["Access-Control-Allow-Headers"] =
    "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
end

options "/*" do |env|
end

get "/releases" do
  Data.versions
end

get "/users" do
  Data.users.values.to_json
end

get "/users/:id" do |env|
  id = env.params.url["id"].to_i32

  Data.users[id]?.to_json
end

delete "/users/:id" do |env|
  id = env.params.url["id"].to_i32

  Data.users.delete(id).to_json
end

put "/users/:id" do |env|
  id = env.params.url["id"].to_i32

  params = {
    "first_name" => env.params.json["first_name"].as(String),
    "last_name"  => env.params.json["last_name"].as(String),
    "status"     => env.params.json["status"].as(String),
    "updated_at" => Time.now.to_s,
  }

  Data.users[id].merge!(params).to_json
end

post "/users" do |env|
  id =
    (Data.users.keys.max? || -1) + 1

  params = {
    "first_name" => env.params.json["first_name"].as(String),
    "last_name"  => env.params.json["last_name"].as(String),
    "status"     => env.params.json["status"].as(String),
    "updated_at" => Time.now.to_s,
    "created_at" => Time.now.to_s,
    "id"         => id.to_s,
  }

  Data.users[id] = params
  params.to_json
end

spawn do
  loop do
    update_versions
    generate_users
    sleep 2.hours
  end
end

port =
  case ENV["PORT"]?
  when String
    ENV["PORT"].to_i
  else
    3001
  end

Kemal.run(port)
