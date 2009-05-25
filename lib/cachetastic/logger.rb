# This class handles logging for the caches and their adapters.
module Cachetastic
  class Logger
  
    # attr_accessor :options
    # attr_accessor :cache_name
    attr_accessor :loggers
  
    def initialize(*loggers)
      @loggers = [loggers].flatten
    end
  
    LOG_LEVELS = [:fatal, :error, :warn, :info, :debug]
  
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