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

  desc "publish GAME_ID", "Download and publish the specified game"
  def publish(game_id)
    ## Details about the destination

    game       = MlbGameList.game(game_id)
    hosted_dir = "/webapps/downloads/alexcast"

    ## Print game details

    puts "Game starts at : #{ game.time }"
    puts "Game matchup   : #{ game.away_team.name } at #{ game.home_team.name }"
    puts "Event ID       : #{ game.id }"
    puts "Status         : #{ game.status }"

    ## If the game isn't final, don't try to download

    unless game.finished?
      puts
      puts "Game is not final, exiting."
      exit
    end

    ## Download the game, encode it to mp3

    j    = "j=#{ [ month, day, year[/\d\d$/] ].join('/') }"
    e    = "e=#{ event_id }"
    a    = "a=#{ requested_team }"
    mp3  = [ a, year + month + day, iteration, "mp3" ].join(".")
    args = [ "mlbplay.py", j, e, a ].map(&:shellwords)

    system "rm -f mlbgame.wav"
    system "python #{ args.join ' ' }" or raise "couldn't finish download"
    system "lame -a mlbgame.wav #{ mp3.shellwords }" or raise "couldn't encode mp3"

    ## Set mp3 tags

    title = "#{ away_team.upcase } at #{ home_team.upcase } - #{ month }/#{ day }/#{ year }-#{ iteration }"

    system "id3v2 --TIT2 #{ Shellwords.escape(title) } #{ Shellwords.escape(mp3) }"
    system "id3v2 --TPE1 #{ Shellwords.escape('Radio Broadcast') } #{ Shellwords.escape(mp3) }"
    system "touch -d '#{ year }-#{ month }-#{ day } #{ time }' #{ Shellwords.escape(mp3) }"

    ## Deploy the new file

    FileUtils.rm_rf "mlbgame.wav"
    FileUtils.mv mp3, hosted_dir
    system File.join(hosted_dir, "render.sh")
  end

end
