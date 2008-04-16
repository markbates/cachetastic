# An adapter/store that keeps objects in local memory. This is great for development/testing,
# but probably shouldn't be put into production. 
# It's also a very good example of how to write a adapter.
class Cachetastic::Adapters::LocalMemory < Cachetastic::Adapters::Base
  
  attr_accessor :local_store
  
  def valid?
    true
  end

  def setup
    self.local_store = {}
  end
  
  def expire_all
    self.local_store = {}
  end
  
  # See Cachetastic::Adapters::Base
  def get(key)
    so = self.local_store[key.to_s]
    if so
      if so.invalid?
        self.delete(key)
        return nil
      end
      return so.value
    end
    return nil
  end
  
  def set(key, value, expiry = 0)
    self.local_store[key.to_s] = Cachetastic::Adapters::StoreObject.new(key.to_s, value, expiry)
  end
  
  def delete(key, delay = 0)
    if delay <= 0
      self.local_store.delete(key.to_s)
    else
      so = self.get(key)
      if so
        self.set(so.key, so.value, delay)
      end
    end
  end
  
  def stats
    super
    num_keys = self.local_store.size
    s = "Number of Entries: #{num_keys}\n"
    if num_keys > 0
      expiries = []
      keys = []
      self.local_store.each do |key,value|
        keys << key
        expiries << value.expires_at
      end
      expiries.sort! {|x, y| x <=> y}
      oldest_expiry = expiries.first
      newest_expiry = expiries.last
      s += "Oldest Entry: #{oldest_expiry}\nNewest Entry: #{newest_expiry}\nKeys: #{keys.inspect}\n"
    end
    puts s + "\n"
  end

  
end