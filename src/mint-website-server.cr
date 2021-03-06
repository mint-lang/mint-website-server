require "kemal"
require "faker"
require "crest"
require "mint/all"

class Data
  class_property users
  class_property versions

  @@versions = ""
  @@users = {} of Int32 => Hash(String, String)
end

def update_versions
  response =
    Crest.get("https://api.github.com/repos/mint-lang/mint/releases")

  Data.versions = response.body
end

def generate_users
  Faker.seed 10

  Array.new(100) do |id|
    Data.users[id] = {
      "status"     => Faker.rng.rand(2) > 0 ? "active" : "locked",
      "updated_at" => Time.now.to_s("%FT%X%z"),
      "created_at" => Time.now.to_s("%FT%X%z"),
      "first_name" => Faker::Name.first_name,
      "last_name"  => Faker::Name.last_name,
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

post "/compile" do |env|
  begin
    runtime =
      Mint::Assets.read("runtime.js")

    body =
      env.request.body.try(&.gets_to_end)

    ast =
      Mint::Parser
        .parse(body.to_s, "Main.mint")
        .merge(Mint::Core.ast)

    type_checker =
      Mint::TypeChecker.new(ast)

    type_checker.check

    compiled =
      Mint::Compiler.compile type_checker.artifacts

    env.response.content_type = "application/javascript"
    runtime + compiled
  rescue error : Mint::Error
    env.response.content_type = "text/html"
    halt env, status_code: 500, response: error.to_html
  end
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
    "updated_at" => Time.now.to_s("%FT%X%z"),
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
    "updated_at" => Time.now.to_s("%FT%X%z"),
    "created_at" => Time.now.to_s("%FT%X%z"),
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
