class MlbRecordingMonitor

  GAME_START_SLEEP_SECONDS  = 60
  GAME_ACTIVE_SLEEP_SECONDS = 120

  attr_reader :game_id
  attr_reader :output_filename_base
  attr_reader :output_filename
  attr_reader :output_index
  attr_reader :start_time
  attr_reader :last_file_size
  attr_reader :child_pid
  attr_reader :started_finished

  def initialize(game_id, output_filename_base)
    @game_id              = game_id
    @output_filename_base = output_filename_base
    @output_index         = 0
    @started_finished     = game_object.finished?
  end

  def record!
    # We have different recording logic for if we started recording after the
    # game was finished versus started recording before the game started or
    # while it's airing. This is because if you connect to the stream after the
    # game has finished, you get playback from the beginning. During the game,
    # you get playback where the game is currently.
    if started_finished
      start_recording!

      while is_child_alive? && is_output_file_growing?
        notice "Game is recording, waiting #{ GAME_ACTIVE_SLEEP_SECONDS } seconds ..."
        sleep GAME_ACTIVE_SLEEP_SECONDS
      end
    else
      while is_child_alive? && is_game_waiting?
        notice "Game is not yet started, waiting #{ GAME_START_SLEEP_SECONDS } seconds ..."
        sleep GAME_START_SLEEP_SECONDS
      end

      until is_game_finished?
        start_recording!

        while is_output_file_growing? && !is_game_finished?
          notice "Game is recording, waiting #{ GAME_ACTIVE_SLEEP_SECONDS } seconds ..."
          sleep GAME_ACTIVE_SLEEP_SECONDS
        end

        finish_recording!
      end
    end

    finish_recording!
    notice "Game has finished!"
  end

  def start_recording!
    # Make sure we don't have a recording in progress.
    finish_recording!

    # Mark our starting point.
    @start_time      = Time.now
    @last_file_size  = 0

    # Get a unique filename.
    while !@output_filename || File.exists?(@output_filename)
      @output_index   += 1
      @output_filename = "%s-%04d.mp3" % [ output_filename_base, output_index ]
    end

    # Fork off the recording process.
    streaming_command = game_object.streaming_command
    recorder = MlbRecorder.new(streaming_command, output_filename)
    @child_pid = wrapped_fork { recorder.record! }
    notice "Forked PID #{ child_pid } with streaming command: #{ streaming_command }"
  end

  def finish_recording!
    Process.kill("KILL", child_pid) if is_child_alive?

    @child_pid      = nil
    @start_time     = nil
    @last_file_size = nil
  end

  def wrapped_fork(&b)
    fork do
      begin
        b.call
      rescue Exception => e
        puts "EXCEPTION!"; STDOUT.flush
      end
    end
  end

  def game_object
    MlbGameList.game(game_id)
  end

  def is_game_waiting?
    game_object.waiting?
  end

  def is_game_started?
    game_object.started?
  end

  def is_game_finished?
    game_object.finished?
  end

  def is_child_alive?
    if child_pid == nil
      false
    else
      Process.kill 0, child_pid
      true
    end
  end

  def is_output_file_growing?
    # Don't give up if we haven't actually started yet.
    return true if start_time == nil
    return true if last_file_size == nil

    # Give the child process a grace period to start growing.
    return true if start_time >= Time.now - 300

    # Update the file size.
    previous_size   = last_file_size
    current_size    = File.size(output_filename)
    @last_file_size = current_size

    # Test to see if the file has grown.
    previous_size < current_size
  end

end
