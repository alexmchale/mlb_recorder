class RecordApp < Thor

  desc "games DATE", "List the games that are available for the given date, defaults to today"
  def games(date = Date.today)
    date = Chronic.parse(date).to_date unless date.kind_of?(Date)

    table = Terminal::Table.new(headings: [ "Game ID", "Home Team", "Away Team", "Status" ])

    MlbGameList.new(date).games.each do |game|
      table << [
        game.id,
        game.home_team.color1 { game.home_team_name },
        game.away_team.color1 { game.away_team_name },
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

    game           = MlbGameList.game(game_id)
    hosted_dir     = "/webapps/downloads/alexcast"
    mlbviewer_root = File.expand_path("../../../mlbviewer2014", __FILE__)
    wavfile        = "/tmp/mlbgame.wav"
    render_sh      = File.join(hosted_dir, "render.sh")

    ## Print game details

    puts "Game starts at : #{ game.time }"
    puts "Game matchup   : #{ game.away_team.name } at #{ game.home_team.name }"
    puts "Event ID       : #{ game.id }"
    puts "Status         : #{ game.status }"
    puts "Venue          : #{ game.venue_name }"
    puts

    ## If the game isn't final, don't try to download

    unless game.finished?
      puts "Game is not final, exiting."
      exit
    end

    ## Download the game, encode it to mp3

    title = "%s at %s - %s-%d" % [
      game.away_team.short_name,
      game.home_team.short_name,
      game.time.strftime('%m/%d/%y'),
      game.game_number,
    ]

    bcast = 'det'
    j     = "j=#{ game.time.strftime('%m/%d/%y') }"
    e     = "e=#{ game.id }"
    a     = "a=#{ bcast }"
    mp3   = [ bcast, game.time.strftime('%Y%m%d'), '1', "mp3" ].join(".")
    args  = [ "#{mlbviewer_root}/mlbplay.py", j, e, a ].map(&:shellwords)
    tags  = { tt: title, ta: game.venue_name, tl: "Major League Baseball", tg: 12 }
    tags  = tags.map { |k, v| "--#{ k } #{ v.to_s.shellwords }" }.join(" ")

    FileUtils.rm_rf wavfile
    sh "python #{ args.join ' ' }" or raise "couldn't finish download"
    sh "lame -a #{ tags } #{ wavfile.shellwords } #{ mp3.shellwords }" or raise "couldn't encode mp3"
    sh "touch -d #{ game.time.iso8601.shellwords } #{ mp3.shellwords }"

    ## Deploy the new file

    FileUtils.rm_rf wavfile
    FileUtils.mv mp3, hosted_dir
    sh render_sh
  end

end
