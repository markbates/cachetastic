module Cachetastic # :nodoc:
  class Cache
    
    class StoreObject # :nodoc:
      attr_accessor :expires_at
      attr_accessor :key
      attr_accessor :value
      
      def initialize(key, value, expires_at)
        self.key = key
        self.value = value
        self.expires_at = expires_at
      end
      
      def expired?
        return Time.now > self.expires_at
      end

      def inspect
        "#<Cachetastic::Cache::StoreObject key='#{self.key}' expires_at='#{self.expires_at}' value='#{self.value}'>"
      end
      
    end # StoreObject
    
  end # Cache
end # Cachetastic