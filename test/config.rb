configatron.my_file_store_cache_options.debug = false
configatron.my_file_store_cache_options.adapter = :file
configatron.my_file_store_cache_options.store_options.dir = '/cachetastic/test'
configatron.my_file_store_cache_options.logger = Logger.new(STDOUT)

configatron.cachetastic_default_options.debug = false
configatron.cachetastic_default_options.adapter = :local_memory
configatron.cachetastic_default_options.marshall_method = :none
configatron.cachetastic_default_options.default_expiry = 2
log = Logger.new(STDOUT)
log.level = Logger::DEBUG
configatron.cachetastic_default_options.logger = log

configatron.young_mc_cache_options.debug = true
configatron.young_mc_cache_options.adapter = :memcache
configatron.young_mc_cache_options.default_expiry = 2
configatron.young_mc_cache_options.logger = Logger.new(STDOUT)
configatron.young_mc_cache_options.servers = "127.0.0.1:11211"
configatron.young_mc_cache_options.store_options.c_threshold = "10_000"
configatron.young_mc_cache_options.store_options.compression = true
configatron.young_mc_cache_options.store_options.debug = false
configatron.young_mc_cache_options.readonly = false
configatron.young_mc_cache_options.urlencode = false

configatron.dr_bob_cache_options.debug = true
configatron.dr_bob_cache_options.adapter = :drb
configatron.dr_bob_cache_options.default_expiry = 2
configatron.dr_bob_cache_options.logger = Logger.new(STDOUT)
configatron.dr_bob_cache_options.servers = "druby://127.0.0.1:61676"
configatron.dr_bob_cache_options.marshall_method = :ruby
