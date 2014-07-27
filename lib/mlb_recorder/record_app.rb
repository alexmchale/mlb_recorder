class RecordApp < Thor

  desc "games DATE", "List the games that are available for the given date, defaults to today"
  def games(date = Date.today)
    # Ensure we've got a date object.
    date = Chronic.parse(date).to_date

    # Prompt for the user's time zone if it's not set.
    Conf.time_zone_name? or Conf.time_zone_name!

    # Build the columns used in the output table.
    columns = -> game {
      {
        "Game ID"   => if game then game.id                end,
        "Time"      => if game then game.local_time_string end,
        "Away Team" => if game then game.away_team.name    end,
        "Home Team" => if game then game.home_team.name    end,
        "Status"    => if game then game.status            end,
      }
    }

    # Output a table with the game listing.
    puts(Terminal::Table.new(headings: columns[nil].keys.map(&:yellow)) do |table|
      MlbGameList.new(date).games.each.with_index do |game, i|
        # Colorize the given string
        color1 = if i%2==0 then :cyan else :blue end
        color2 = 0

        # Override the colors for favorite team
        if [ game.home_team, game.away_team ].include?(Conf.favorite_team)
          color1 = 220
          color2 = 17
        end

        # Add the table row
        table << columns[game].values.map do |x|
          x.to_s.color(color1).on_color(color2)
        end
      end
    end)
  end

  desc "record GAME_ID", "Record the specified game"
  def record(game_id)
    path = File.expand_path("~/Music/Tigers/tigers-game")
    MlbRecordingMonitor.new(game_id, path).record!
  end

  desc "publish GAME_ID", "Download and publish the specified game"
  def publish(game_id)
    ## Get game details

    game_spec = game_id.split(",")

    game =
      if game_spec.length == 1
        MlbGameList.game(game_id)
      elsif game_spec.length == 2
        list  = MlbGameList.new(Date.parse(game_spec[0]))
        games = list.find_with_team(game_spec[1])
        games[0]
      elsif game_spec.length == 3
        list  = MlbGameList.new(Date.parse(game_spec[0]))
        games = list.find_with_team(game_spec[1])
        games.find { |game| game.game_number == Integer(game_spec[2]) }
      end

    raise "game not found" unless game.kind_of? MlbGame

    ## Details about the destination

    hosted_dir     = "/webapps/downloads/alexcast"
    mlbviewer_root = File.expand_path("../../../mlbviewer2014", __FILE__)
    wavfile        = "/tmp/mlbgame.wav"
    render_sh      = File.join(hosted_dir, "render.sh")

    ## Print game details

    table = Terminal::Table.new

    table << [ "ID"      .yellow, game.id                                                .green ]
    table << [ "Time"    .yellow, game.time.to_s                                         .green ]
    table << [ "Matchup" .yellow, "#{ game.away_team.name } at #{ game.home_team.name }" .green ]
    table << [ "Status"  .yellow, game.status                                            .green ]
    table << [ "Venue"   .yellow, game.venue_name                                        .green ]

    puts table

    ## If the game isn't final, don't try to download

    unless game.finished?
      puts
      puts "Game is not final, exiting.".red
      exit
    end

    ## Download the game, encode it to mp3

    title = "%s at %s - %s-%d" % [
      game.away_team.short_name,
      game.home_team.short_name,
      game.time.strftime('%m/%d/%y'),
      game.game_number,
    ]

    mp3  = [ bcast, game.time.strftime('%Y%m%d'), '1', "mp3" ].join(".")
    tags = { tt: title, ta: game.venue_name, tl: "Major League Baseball", tg: 12 }
    tags = tags.map { |k, v| "--#{ k } #{ v.to_s.shellwords }" }.join(" ")

    FileUtils.rm_rf wavfile
    sh game.streaming_command(filename: wavfile) or die "Could not get the audio stream."
    sh "lame -a #{ tags } #{ wavfile.shellwords } #{ mp3.shellwords }" or die "Could not encode MP3."
    sh "touch -d #{ game.time.iso8601.shellwords } #{ mp3.shellwords }"

    ## Deploy the new file

    FileUtils.rm_rf wavfile
    FileUtils.mv mp3, hosted_dir
    sh render_sh
  end

  desc "stream GAME_ID WAVFILE", "Stream the specified game to a wav file"
  def stream(game_id, path)
    ## Get game details

    game_spec = game_id.split(",")

    game =
      if game_spec.length == 1
        MlbGameList.game(game_id)
      elsif game_spec.length == 2
        list  = MlbGameList.new(Date.parse(game_spec[0]))
        games = list.find_with_team(game_spec[1])
        games[0]
      elsif game_spec.length == 3
        list  = MlbGameList.new(Date.parse(game_spec[0]))
        games = list.find_with_team(game_spec[1])
        games.find { |game| game.game_number == Integer(game_spec[2]) }
      end

    raise "game not found" unless game.kind_of? MlbGame

    ## Print game details

    puts(Terminal::Table.new do |table|
      table << [ "ID"      .yellow, game.id                                                .green ]
      table << [ "Time"    .yellow, game.time.to_s                                         .green ]
      table << [ "Matchup" .yellow, "#{ game.away_team.name } at #{ game.home_team.name }" .green ]
      table << [ "Status"  .yellow, game.status                                            .green ]
      table << [ "Venue"   .yellow, game.venue_name                                        .green ]
    end)

    ## Stream to disk

    FileUtils.rm_rf path
    sh game.streaming_command(filename: path) or die "Could not get the audio stream."
  end

  desc "favorite", "Set your favorite team"
  def favorite
    choose do |menu|
      menu.prompt = "What is your favorite team? "
      menu.choices(*MlbTeam.all.map(&:name)) do |team_name|
        Conf.favorite_team_name = team_name
      end
    end
  end

  desc "mlbauth USERNAME PASSWORD", "Set your MLB.TV credentials"
  def setauth(username, password)
    Conf.mlb_username = username
    Conf.mlb_password = password

    puts "MLB.TV authentication has been configured.".green
  end

end
