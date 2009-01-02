module Cachetastic
  # Include this module into an Object to achieve simplistic Object level caching.
  # 
  # Example:
  #   class Person
  #     include Cachetastic::Cacheable
  #   
  #     attr_accessor :name
  #   
  #     def cachetastic_key
  #       self.name
  #     end
  #   
  #     def always_the_same(x, y)
  #       cacher("always_the_same") do
  #         x + y
  #       end
  #     end
  #   
  #   end
  module Cacheable
    
    module ClassAndInstanceMethods
      # Returns the Cachetastic::Caches::Base object associated with the object.
      # If a cache hasn't been defined the one will be created on the fly.
      # The cache for the object is expected to be defined as:
      # Cachetastic::Cacheable::{CLASS_NAME_HERE}Cache
      # 
      # Example:
      #   class Person
      #     include Cachetastic::Cacheable
      #     attr_accessor :name
      #     def cachetastic_key
      #       self.name
      #     end
      #   end
      # 
      #  Person.cache_class # => Cachetastic::Cacheable::PersonCache
      def cache_class
        n = self.class.name
        n = self.name if n == "Class"
        # puts "n: #{n}"
        c_name = "Cachetastic::Cacheable::#{n}Cache"
        begin
          return c_name.constantize
        rescue NameError => e
          eval %{
            class #{c_name} < Cachetastic::Caches::Base
            end
          }
          return c_name.constantize
        end
        
      end
    
      # How much did I want to call this method cache?? It originally was that, but
      # in Rails 2.0 they decided to use that name, so I had to rename this method.
      # This method will attempt to get an object from the cache for a given key.
      # If the object is nil and a block is given the block will be run, and the results
      # of the block will be automatically cached.
      # 
      # Example:
      #   class Person
      #     include Cachetastic::Cacheable
      #     attr_accessor :name
      #     def cachetastic_key
      #       self.name
      #     end
      #     def always_the_same(x,y)
      #       cacher("always_the_same") do
      #         x + y
      #       end
      #     end
      #   end
      # 
      #   Person.new.always_the_same(1,2) # => 3
      #   Person.new.always_the_same(2,2) # => 3
      #   Person.new.always_the_same(3,3) # => 3
      #   Person.cacher("always_the_same") # => 3
      #   Person.get_from_cache("always_the_same") # => 3
      #   Cachetastic::Cacheable::PersonCache.get("always_the_same") # => 3
      #   
      #   Person.cacher("say_hi") {"Hi There"} # => "Hi There"
      #   Person.get_from_cache("say_hi") # => "Hi There"
      #   Cachetastic::Cacheable::PersonCache.get("say_hi") # => "Hi There"
      def cacher(key, expiry = 0)
        cache_class.get(key) do
          if block_given?
            res = yield
            cache_class.set(key, res, expiry)
          end
        end
      end
    
      # Expires the entire cache associated with this objects's cache.
      # 
      # Example:
      #   class Person
      #     include Cachetastic::Cacheable
      #     attr_accessor :name
      #     def cachetastic_key
      #       self.name
      #     end
      #   end
      # 
      #   Person.set_into_cache(1, "one")
      #   Person.get_from_cache(1) # => "one"
      #   Person.expire_all
      #   Person.get_from_cache(1) # => nil
      #   Person.set_into_cache(1, "one")
      #   Person.get_from_cache(1) # => "one"
      #   Cachetastic::Cacheable::PersonCache.expire_all
      #   Person.get_from_cache(1) # => nil
      def expire_all
        cache_class.expire_all
      end
    end
    
    # --------------------------
    # Instance only methods:
    
    # Unless the object's cachetastic_key method returns nil this method will store
    # the object in the cache using the object's cachetastic_key as the key.
    # You *MUST* create an instance level method called cachetastic_key and 
    # have it return a valid key! If you return nil from the cachetastic_key method or you will not be
    # able to use the cache_self and uncache_self methods.
    # 
    # Example:
    #   class Person
    #     include Cachetastic::Cacheable
    #     attr_accessor :name
    #     def cachetastic_key
    #       self.name
    #     end
    #   end
    # 
    #   Person.get_from_cache("Mark Bates") # => nil
    #   p = Person.new
    #   p.name = "Mark Bates"
    #   p.cache_self
    #   Person.get_from_cache("Mark Bates") # => "Mark Bates"
    def cache_self
      cache_class.set(self.cachetastic_key, self) unless self.cachetastic_key.nil?
    end

    # Unless the object's cachetastic_key method returns nil this method will delete
    # the object in the cache using the object's cachetastic_key as the key.
    # You *MUST* create an instance level method called cachetastic_key and 
    # have it return a valid key! If you return nil from the cachetastic_key method or you will not be
    # able to use the cache_self and uncache_self methods.
    # 
    # Example:
    #   class Person
    #     include Cachetastic::Cacheable
    #     attr_accessor :name
    #     def cachetastic_key
    #       self.name
    #     end
    #   end
    # 
    #   Person.get_from_cache("Mark Bates") # => nil
    #   p = Person.new
    #   p.name = "Mark Bates"
    #   p.cache_self
    #   Person.get_from_cache("Mark Bates") # => "Mark Bates"
    #   p.uncache_self
    #   Person.get_from_cache("Mark Bates") # => nil
    def uncache_self
      cache_class.delete(self.cachetastic_key) unless self.cachetastic_key.nil?
    end
    
    # --------------------------
    
    def self.included(klass) # :nodoc:
      klass.send(:include, ClassAndInstanceMethods)
      klass.extend(ClassOnlyMethods)
      klass.extend(ClassAndInstanceMethods)
    end
    
    module ClassOnlyMethods
      # Returns an object from the cache for a given key.
      def get_from_cache(key, &block)
        cache_class.get(key, &block)
      end

      # Deletes an object from the cache for a given key.
      def delete_from_cache(key)
        cache_class.delete(key)
      end

      # Sets an object into the cache for a given key.
      def set_into_cache(key, value, expiry = 0)
        cache_class.set(key, value, expiry)
      end
    end # ClassMethods
    
  end # Cacheable
end # Cachetastic