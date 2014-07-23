module Kernel

  def notice(message)
    puts "(#{ Time.now.iso8601 }) ---> #{ message }"
  end

  def sh(command)
    puts
    notice command
    puts
    result = system command
    puts
    result
  end

end

class String

  def shellwords
    Shellwords.escape(self)
  end

end
