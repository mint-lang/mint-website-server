require "kemal"
require "faker"

USERS    = {} of Int32 => Hash(String, String)
STATUSES = ["active", "locked"]

def generate_users
  Faker.seed 10

  Array.new(100) do |id|
    USERS[id] = {
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

get "/users" do
  USERS.values.to_json
end

get "/users/:id" do |env|
  id = env.params.url["id"].to_i32

  USERS[id]?.to_json
end

delete "/users/:id" do |env|
  id = env.params.url["id"].to_i32

  USERS.delete(id).to_json
end

put "/users/:id" do |env|
  id = env.params.url["id"].to_i32

  params = {
    "first_name" => env.params.json["first_name"].as(String),
    "last_name"  => env.params.json["last_name"].as(String),
    "status"     => env.params.json["status"].as(String),
    "updated_at" => Time.now.to_s,
  }

  USERS[id].merge!(params).to_json
end

post "/users" do |env|
  id =
    (USERS.keys.max? || -1) + 1

  params = {
    "first_name" => env.params.json["first_name"].as(String),
    "last_name"  => env.params.json["last_name"].as(String),
    "status"     => env.params.json["status"].as(String),
    "updated_at" => Time.now.to_s,
    "created_at" => Time.now.to_s,
    "id"         => id.to_s,
  }

  USERS[id] = params
  params.to_json
end

# Reset every two hours
spawn do
  generate_users
  sleep 2.hours
end

port =
  case ENV["PORT"]?
  when String
    ENV["PORT"].to_i
  else
    3001
  end

Kemal.run(port)
