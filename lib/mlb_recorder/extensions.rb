module Kernel

  def notice(message)
    puts "#{ Time.now.iso8601.yellow } ---> #{ message.green }"
  end

  def sh(command)
    puts
    notice command
    puts
    result = system command
    puts
    result
  end

  def eastern_time_zone
    $eastern_time_zone ||=
      ActiveSupport::TimeZone.us_zones.find do |zone|
        zone.name =~ /eastern/i
      end
  end

  def die(message)
    puts
    puts message.to_s.red
    exit 1
  end

end

class String

  include Term::ANSIColor

  def shellwords
    Shellwords.escape(self)
  end

end
