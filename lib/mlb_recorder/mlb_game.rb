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

  def streaming_command
    mlbviewer_py       = "mlbviewer2014/mlbplay.py"
    event_id           = "event_id=#{ id }"
    audio              = "audio=det" # TODO - Make this flexible
    start_date         = "startdate=#{ date.strftime('%m/%d/%y') }"
    debug              = "debug=1"
    args               = [ mlbviewer_py, event_id, audio, start_date, debug ].map(&:shellwords)
    mlbviewer_response = `/usr/bin/python #{ args.join(' ') } 2>&1`

    case mlbviewer_response
    when %r[Requested Media Not Available Yet]m
      raise GameNotStarted
    when %r[Media URL received:.*(^rtmpdump.*?) \| mplayer]m
      $1
    else
      raise MediaNotFound, "Cannot find URL in: #{ mlbviewer_response.inspect }"
    end
  end

  def waiting?   ; status =~ /#{ STATUS_WAITING.join '|' }/i   ; end
  def started?   ; status =~ /#{ STATUS_STARTED.join '|' }/i   ; end
  def finished?  ; status =~ /#{ STATUS_FINISHED.join '|' }/i  ; end
  def cancelled? ; status =~ /#{ STATUS_CANCELLED.join '|' }/i ; end

end
