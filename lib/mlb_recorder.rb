begin

  require "time"
  require "date"
  require "net/http"
  require "json"
  require "shellwords"

  require "ap"
  require "thor"
  require "terminal-table"
  require "chronic"
  require "active_support/time"
  require "term/ansicolor"
  require "typhoeus"

  require "mlb_recorder/extensions"
  require "mlb_recorder/mlb_recorder"
  require "mlb_recorder/mlb_recording_monitor"
  require "mlb_recorder/mlb_game_list"
  require "mlb_recorder/mlb_game"
  require "mlb_recorder/mlb_team"
  require "mlb_recorder/record_app"

rescue LoadError

  puts "gem install --no-rdoc --no-ri awesome_print thor terminal-table chronic activesupport term-ansicolor typhoeus"
  exit

end
