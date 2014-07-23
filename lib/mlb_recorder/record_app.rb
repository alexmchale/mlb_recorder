class RecordApp < Thor

  desc "games DATE", "List the games that are available for the given date, defaults to today"
  def games(date = Date.today)
    date = Chronic.parse(date).to_date unless date.kind_of?(Date)

    table = Terminal::Table.new(headings: [ "Game ID", "Home Team", "Away Team", "Status" ])

    MlbGameList.new(date).games.each do |game|
      table << [
        game.id,
        game.home_team_name,
        game.away_team_name,
        game.status,
      ]
    end

    puts table
  end

  desc "record GAME_ID", "Record the specified game"
  def record(game_id)
    path = File.expand_path("~/Music/Tigers/tigers-game")
    MlbRecordingMonitor.new(game_id, path).record!
  end

end
