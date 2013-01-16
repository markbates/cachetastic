module Cachetastic # :nodoc:
  module Adapters
    # An adapter to cache objects to memory. It is important to note
    # that this cache is <b>volatile</b>. If the VM it is running in
    # shuts down, everything in the cache gets vaporized.
    # 
    # See <tt>Cachetastic::Adapters::Base</tt> for a list of public API
    # methods.
    class LocalMemory < Cachetastic::Adapters::Base
      
      def initialize(klass) # :nodoc:
        super
        @_store = {}
      end
      
      def get(key) # :nodoc:
        @_store[key]
      end # get
      
      def set(key, value, expiry_time = configatron.cachetastic.defaults.default_expiry) # :nodoc:
        so = Cachetastic::Cache::StoreObject.new(key, value, expiry_time.from_now)
        @_store[key] = marshal(so)
        value
      end # set
      
      def delete(key) # :nodoc:
        @_store.delete(key)
      end # delete
      
      def expire_all # :nodoc:
        @_store = {}
        return nil
      end # expire_all
      
    end # LocalMemory
  end # Adapters
end # Cachetastic