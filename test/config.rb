configatron do |config|
  config.my_file_store_cache_options do |c|
    c.debug = false
    c.adapter = :file
    c.store_options do |so|
      so.dir = "/cachetastic/test"
    end
  end
  config.cachetastic_default_options do |c|
    c.debug = true
    c.adapter = :local_memory
    c.marshall_method = :none
    c.default_expiry = 2
    c.logging do |log|
      log.logger_2 do |l|
        l.type = :console
        l.level = :debug
      end
    end
  end
end