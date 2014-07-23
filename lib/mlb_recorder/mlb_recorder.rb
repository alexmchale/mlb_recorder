class MlbRecorder

  attr_reader :streaming_command
  attr_reader :encoding_command
  attr_reader :output_filename

  def initialize(streaming_command, output_filename)
    @streaming_command = streaming_command
    @encoding_command  = "/usr/bin/avconv -i - -c copy #{ Shellwords.escape output_filename }"
    @output_filename   = output_filename
  end

  def record!
    system "#{ streaming_command } | #{ encoding_command }"
  end

end
