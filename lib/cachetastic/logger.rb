module Cachetastic # :nodoc:
  # This class handles logging for the caches and their adapters.
  # This class exists simply to supply the ability to write to 
  # multiple loggers simultaneously from a single call. It also 
  # creates a standardized message to write to those loggers.
  # 
  # It is important that any logger type of class you decide to use
  # reponds to the following methods:
  #   fatal(message)
  #   error(message)
  #   warn(message)
  #   info(message)
  #   debug(message)
  class Logger
  
    # An <tt>Array</tt> of 'real' loggers to write to.
    attr_accessor :loggers
  
    # The <tt>initialize</tt> method takes an <tt>Array</tt>
    # of your favorite logger style classes to write to.
    def initialize(*loggers)
      @loggers = [loggers].flatten
    end
  
    LOG_LEVELS = [:fatal, :error, :warn, :info, :debug] # :nodoc:
  
    LOG_LEVELS.each do |level|
      define_method(level) do |*args|
        lm = "[CACHE] [#{level.to_s.upcase}]\t#{Time.now.strftime("%m/%d/%y %H:%M:%S")}"
        exs = []
        args.each do |arg|
          if arg.is_a?(Exception)
            exs << arg
            continue
          end
          lm << "\t" << arg.to_s 
        end
        exs.each do |ex|
          lm << "\n#{ex.message}\n" << ex.backtrace.join("\n")
        end
        # puts "lm: #{lm}"
        self.loggers.each do |log|
          log.send(level, lm)
        end
      end
    end
  
  end # Logger
end # Cachetastic