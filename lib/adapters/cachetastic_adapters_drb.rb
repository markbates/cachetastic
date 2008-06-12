# This adapter uses Cachetastic::Drb::Server as it's backing.
# The configuration for this should look something like this:
#  my_awesome_cache_options:
#    debug: false
#    adapter: drb
#    store_options:
#      host: druby://127.0.0.1:61676
class Cachetastic::Adapters::Drb < Cachetastic::Adapters::Base
  
  attr_accessor :drb_store
  
  def valid?
    begin
      return self.drb_store.ping
    rescue Exception => e
      return false
    end
  end

  def setup
    # self.all_options["marshall_method"] = "ruby"
    self.drb_store = DRbObject.new_with_uri(configuration.servers)
  end
  
  def expire_all
    self.drb_store.expire_all(self.name)
  end
  
  # See Cachetastic::Adapters::Base
  def get(key)
    Cachetastic::Caches::Base.unmarshall(self.drb_store.get(self.name, key))
  end
  
  def set(key, value, expiry = 0)
    self.drb_store.set(self.name, key, Cachetastic::Caches::Base.marshall(value), expiry)
  end
  
  def delete(key, delay = 0)
    self.drb_store.delete(self.name, key)
  end
  
  def stats
    super
    begin
      self.drb_store.stats if self.drb_store.respond_to? 'stats'
    rescue Exception => e
      puts "Calling stats on the DRb store raised this exception: #{e.message}"
    end
  end
  
end