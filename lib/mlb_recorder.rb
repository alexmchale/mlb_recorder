# Ensure this file's path is in the load path
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

# Load standard libraries
require "time"
require "date"
require "net/http"
require "json"
require "shellwords"
require "rubygems"
require "yaml"

# Load rubygems
pwd = Dir.pwd
Dir.chdir(File.expand_path("../..", __FILE__))
require "bundler/setup"
Bundler.require(:default)
Dir.chdir(pwd)

# Load local libraries
require "mlb_recorder/exceptions"
require "mlb_recorder/config"
require "mlb_recorder/extensions"
require "mlb_recorder/mlb_recorder"
require "mlb_recorder/mlb_recording_monitor"
require "mlb_recorder/mlb_game_list"
require "mlb_recorder/mlb_game"
require "mlb_recorder/mlb_team"
require "mlb_recorder/record_app"
