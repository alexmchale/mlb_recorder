require File.expand_path("../../lib/mlb_recorder", __FILE__)
require "sinatra"

configure do
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir     = "views"
  end

  set :sass, Compass.sass_engine_options
  set :scss, Compass.sass_engine_options
end

get "/" do
  slim :app
end

get "/app.css" do
  sass :app
end

get "/app.js" do
  coffee :app
end
