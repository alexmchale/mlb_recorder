class RecordApp < Thor

  desc "games DATE", "List the games that are available for the given date, defaults to today"
  def games(date = Date.today)
    time = -> game {
      game.time.in_time_zone(
        if Conf.time_zone_name?
          Conf.time_zone
        else
          game.home_team.time_zone
        end
      ).strftime("%m/%d/%y %I%P").gsub(/ 0/, " ").gsub(/^0+/, "")
    }

    columns = -> game {
      {
        "Game ID"   => if game then game.id             end,
        "Time"      => if game then time[game]          end,
        "Away Team" => if game then game.away_team.name end,
        "Home Team" => if game then game.home_team.name end,
        "Status"    => if game then game.status         end,
      }
    }

    unless Conf.time_zone_name?
      choose do |menu|
        menu.prompt = "What's your time zone? "
        menu.choices(*ActiveSupport::TimeZone.us_zones.map(&:name)) do |choice|
          Conf.time_zone_name = choice
        end
      end
    end

    date  = Chronic.parse(date).to_date unless date.kind_of?(Date)
    table = Terminal::Table.new(headings: columns[nil].keys.map(&:yellow))

    MlbGameList.new(date).games.each.with_index do |game, i|
      # Colorize the given string
      color = -> string {
        if [ game.home_team, game.away_team ].include? Conf.favorite_team
          string.to_s.yellow
        elsif i%2 == 0
          string.to_s.cyan
        else
          string.to_s.blue
        end
      }

      table << columns[game].values.map { |x| color[x] }
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

  desc "favorite", "Set your favorite team"
  def favorite
    choose do |menu|
      menu.prompt = "What is your favorite team? "
      menu.choices(*MlbTeam.all.map(&:name)) do |team_name|
        Conf.favorite_team_name = team_name
      end
    end
  end

end
