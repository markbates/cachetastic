module Cachetastic
  module Helpers
    # These helpers get added to ActiveRecord at both class and instance levels.
    module ActiveRecord
      
      # Returns the Cachetastic::Caches::Base object associated with the ActiveRecord model.
      # If a cache hasn't been defined the one will be created on the fly.
      # The cache for the ActiveRecord model is expected to be defined as:
      # Cachetastic::Caches::ActiveRecord::MODEL_NAME_HERE
      def cache_class
        n = self.class.name
        n = self.name if n == "Class"
        # puts "n: #{n}"
        c_name = "Cachetastic::Caches::ActiveRecord::#{n}Cache"
        unless Cachetastic::Caches::ActiveRecord.const_defined?("#{n}Cache")
          # puts "we need to create a cache for: #{c_name}"
          eval %{
            class #{c_name} < Cachetastic::Caches::Base
            end
          }
        end
        c_name.constantize
      end
      
      # How much did I want to call this method cache?? It originally was that, but
      # in Rails 2.0 they decided to use that name, so I had to rename this method.
      # This method will attempt to get an object from the cache for a given key.
      # If the object is nil and a block is given the block will be run, and the results
      # of the block will be automatically cached.
      def cacher(key, expiry = 0)
        cache_class.get(key) do
          if block_given?
            res = yield
            cache_class.set(key, res, expiry)
          end
        end
      end
      
      # Expires all the objects associated with this ActiveRecord model's cache.
      def expire_all
        cache_class.expire_all
      end
      
    end
  end
end