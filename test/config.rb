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
  config.namespace(:young_mc_cache_options) do |c|
    c.debug = true
    c.adapter = :memcache
    c.default_expiry = 2
    c.logger = Logger.new(STDOUT)
    c.servers = "127.0.0.1:11211"
    c.store_options = {
      :c_threshold => "10_000",
      :compression => true,
      :debug => false,
      :readonly => false,
      :urlencode => false
    }
  end
  config.namespace(:dr_bob_cache_options) do |c|
    c.debug = true
    c.adapter = :drb
    c.default_expiry = 2
    c.logger = Logger.new(STDOUT)
    c.servers = "druby://127.0.0.1:61676"
    c.marshall_method = :ruby
  end
end