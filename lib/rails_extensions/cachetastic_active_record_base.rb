class ActiveRecord::Base
  
  include Cachetastic::Cacheable
  
  def cachetastic_key
    self.id
  end
  
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