configatron do |config|
  config.namespace(:my_file_store_cache_options) do |c|
    c.debug = false
    c.adapter = :file
    c.namespace(:store_options) do |so|
      so.dir = "/cachetastic/test"
    end
    c.logger = Logger.new(STDOUT)
  end
  config.namespace(:cachetastic_default_options) do |c|
    c.debug = true
    c.adapter = :local_memory
    c.marshall_method = :none
    c.default_expiry = 2
    log = Logger.new(STDOUT)
    log.level = Logger::DEBUG
    c.logger = log
  end
end