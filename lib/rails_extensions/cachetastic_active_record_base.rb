class ActiveRecord::Base
  
  include Cachetastic::Cacheable # include helpers at instance level
  
  class << self
    include Cachetastic::Cacheable # include helpers at class level
    
    # Returns an object from the cache for a given key.
    # If the object returned is nil and the self_populate parameter is true
    # then the key will be used to try and find the object in the database,
    # set the object into the cache, and then return the object.
    def get_from_cache(key, self_populate = false)
      res = cache_class.get(key)
      if res.nil? && self_populate
        res = self.name.constantize.find(key)
        unless res.nil?
          res.cache_self
        end
      end
      res
    end
    
    # Deletes an object from the cache for a given key.
    def delete_from_cache(key)
      cache_class.delete(key)
    end
    
    # Sets an object into the cache for a given key.
    def set_into_cache(key, value, expiry = 0)
      cache_class.set(key, value, expiry)
    end
    
  end
  
  # Unless the object is a new ActiveRecord object this method will store
  # the object in the cache using the object's ID as the key.
  def cache_self
    cache_class.set(self.id, self) unless self.new_record?
  end
  
  # Unless the object is a new ActiveRecord object this method will delete
  # the object in the cache using the object's ID as the key.
  def uncache_self
    cache_class.delete(self.id) unless self.new_record?
  end
  
end