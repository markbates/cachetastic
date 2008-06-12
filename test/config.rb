configatron do |config|
  config.namespace(:my_file_store_cache_options) do |c|
    c.debug = false
    c.adapter = :file
    c.namespace(:store_options) do |so|
      so.dir = "/cachetastic/test"
    end
  end
  config.namespace(:cachetastic_default_options) do |c|
    c.debug = true
    c.adapter = :local_memory
    c.marshall_method = :none
    c.default_expiry = 2
    # c.namespace(:logging) do |log|
    #   log.namespace(:logger_2) do |l|
    #     l.type = :console
    #     l.level = :debug
    #   end
    # end
    c.logger = Logger.new(STDOUT)
  end
end