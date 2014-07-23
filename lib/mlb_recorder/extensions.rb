module Kernel

  def notice(message)
    puts "(#{ Time.now.iso8601 }) ---> #{ message }"
  end

end

class String

  def shellwords
    Shellwords.escape(self)
  end

end
