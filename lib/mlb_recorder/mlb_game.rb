class MlbGame

  attr_reader :id
  attr_reader :time, :game_number
  attr_reader :home_team, :home_team_name
  attr_reader :away_team, :away_team_name
  attr_reader :venue_name
  attr_reader :status

  STATUS_WAITING   = [ "Preview", "Delayed Start", "Pre-Game" ]
  STATUS_STARTED   = [ "Warmup", "In Progress", "Manager Challenge", "Delayed" ]
  STATUS_FINISHED  = [ "Final", "Game Over" ]
  STATUS_CANCELLED = [ "Postponed", "Suspended" ]
  STATUS_ALL       = STATUS_WAITING + STATUS_STARTED + STATUS_FINISHED + STATUS_CANCELLED

  def initialize(game_data)
    @game_data      = game_data
    @id             = @game_data["calendar_event_id"]
    @home_team_name = @game_data["home_team_name"]
    @home_team      = MlbTeam.find(@home_team_name)
    @away_team_name = @game_data["away_team_name"]
    @away_team      = MlbTeam.find(@away_team_name)
    @status         = @game_data["status"]
    @time           = eastern_time_zone.parse("#{ date } #{ @game_data['event_time'] }")
    @game_number    = Integer(@game_data["game_nbr"])
    @venue_name     = @game_data["venue"]

    # Verify that we know about the specified game status.
    unless STATUS_ALL.include? @status
      die "Unknown game status #{ @status.inspect }."
    end
  end

  def date
    Date.parse(id[/^\d+-\d+-(\d{4}-\d{2}-\d{2})$/, 1])
  end

  def streaming_command(filename: "/tmp/mlbgame.wav", team: Conf.favorite_team, live: false, stdout: false)
    # Write the MLB configuration file.
    audio_player = "mplayer -cache 512 -vo null -ao pcm:file=#{ File.expand_path(filename).shellwords }"
    File.open(File.expand_path("~/.mlb/config"), "w") do |f|
      f.puts(<<-CONFIG.gsub(/^\s+/, ""))
        # See README for explanation of these settings.
        # user and pass are required except for Top Plays
        user=#{ Conf.mlb_username }
        pass=#{ Conf.mlb_password }
        video_player=mplayer -cache 4096
        audio_player=#{ audio_player }
        favorite=
        use_nexdef=0
        speed=1200
        min_bps=1200
        max_bps=2400
        adaptive_stream=0
        live_from_start=#{ if live then 0 else 1 end }
        # Many more options are available and documented at:
        # http://sourceforge.net/p/mlbviewer/wiki/Home/
      CONFIG
    end

    # Make sure the requested team exists in this game.
    team = home_team unless team == away_team

    # Build parameters for mlbplay command.
    mlbviewer_py       = File.join(Conf.app_root, "mlbviewer2014", "mlbplay.py")
    event_id           = "event_id=#{ id }"
    audio              = "audio=#{ team.code }"
    start_date         = "startdate=#{ date.strftime('%m/%d/%y') }"
    debug              = "debug=1"
    args               = [ mlbviewer_py, event_id, audio, start_date, debug ].map(&:shellwords)
    mlbviewer_response = `/usr/bin/python #{ args.join(' ') } 2>&1`

    # Find the rtmpdump command printed in the output.
    case mlbviewer_response
    when %r[Requested Media Not Available Yet]m
      raise GameNotStarted
    when %r[Media URL received:.*(^rtmpdump.*?) \| mplayer]m
      if stdout
        $1
      else
        "#{ $1 } | #{ audio_player } -"
      end
    else
      raise MediaNotFound, "Cannot find URL in: #{ mlbviewer_response.inspect }"
    end
  end

  def local_time_string
    time.in_time_zone(
      if Conf.time_zone_name?
        Conf.time_zone
      else
        home_team.time_zone
      end
    ).strftime("%m/%d/%y %I%P").gsub(/ 0/, " ").gsub(/^0+/, "")
  end

  def waiting?   ; status =~ /#{ STATUS_WAITING.join '|' }/i   ; end
  def started?   ; status =~ /#{ STATUS_STARTED.join '|' }/i   ; end
  def finished?  ; status =~ /#{ STATUS_FINISHED.join '|' }/i  ; end
  def cancelled? ; status =~ /#{ STATUS_CANCELLED.join '|' }/i ; end

end
