# This adapter uses Memcache as it's backing.
# The configuration for this should look something like this:
#  my_awesome_cache_options:
#    debug: false
#    adapter: memcache
#    marshall_method: none
#    default_expiry: <%= 24.hours %>
#    store_options:  
#      c_threshold: 10_000
#      compression: true
#      debug: false
#      readonly: false
#      urlencode: false
#    logging:
#      logger_1:
#        type: file
#        file: log/memcached.log
#    servers:
#      - 127.0.0.1:11211
class Cachetastic::Adapters::Memcache < Cachetastic::Adapters::Base
  
  def setup
    self.conn = MemCache.new(configuration.servers, configuration.store_options.to_hash.merge({:namespace => self.namespace}))
    self.version = self.get_version(self.name)
  end
  
  def set(key, value, expiry = 0, raw = false)
    self.conn.set(key, value, expiry, raw)
  end
  
  def delete(key, delay = 0)
    self.conn.delete(key, delay)
  end
  
  def get(key, raw = false)
    self.conn.get(key, raw)
  end
  
  def expire_all
    self.increment_version(self.name)
  end
  
  def inspect
    self.conn.inspect + " <version: #{self.version}> #{self.conn.stats.inspect}"
  end
  
  def valid?
    begin
      return (self.conn.active? && self.version == self.get_version(self.name))
    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n")
      return false
    end
  end
  
  def stats
    super
    begin
      puts "Memcache stats for all caches:"
      memc = self.conn
      puts Kernel.pp_to_s(memc.stats)
      paths = `sh -c 'echo $PATH'`
      paths = paths.split(':')
      memcached_tool_found = false
      paths.each do |path|
        cmd_path = File.expand_path(File.join(path,'memcached_tool'))
        if File.exists?(cmd_path)
           memcached_tool_found = true
          break
        end
      end
      if memcached_tool_found
        configuration.memcache_servers.each do |server|
          puts `memcached_tool #{server}`
        end
      end
    rescue
    end
    puts ""
  end
  
  protected
  attr_accessor :conn
  attr_accessor :version
  
  def namespace
    v = self.get_version(self.name)
    return "#{name}.#{v}"
  end
  
  def ns_versions
    ivar_cache do
      ns_conn = MemCache.new(configuration.servers, configuration.store_options.to_hash.merge({:namespace => :namespace_versions}))
    end
  end
  
  def increment_version(name)
    name = name.to_s
    v = get_version(name)
    self.ns_versions.set(name, v + 1)
  end

  def get_version(name)
    name = name.to_s
    v = self.ns_versions.get(name)
    if v.nil?
      self.ns_versions.set(name, 1)
      v = 1
    end
    v
  end
  
end