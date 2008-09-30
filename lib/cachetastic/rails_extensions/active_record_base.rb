class ActiveRecord::Base
  
  include Cachetastic::Cacheable
  
  def cachetastic_key
    self.id
  end
  
  # Returns an object from the cache for a given key.
  # If the object returned is nil and the self_populate parameter is true
  # then the key will be used to try and find the object in the database,
  # set the object into the cache, and then return the object.
  def self.get_from_cache(key, self_populate = false)
    res = cache_class.get(key)
    if res.nil? && self_populate
      res = self.name.constantize.find(key)
      unless res.nil?
        res.cache_self
      end
    end
    res
  end
  
end