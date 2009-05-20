module Cachetastic
  module Adapters
    class LocalMemory < Cachetastic::Adapters::Base
      
      def initialize(klass)
        super
        @_store = {}
      end
      
      def get(key, &block)
        @_store[key]
      end # get
      
      def set(key, value, expiry_time = nil)
        so = Cachetastic::Cache::StoreObject.new(key, value, calculate_expiry_time(expiry_time).from_now)
        @_store[key] = marshal(so)
        value
      end # set
      
      def delete(key)
        @_store.delete(key)
      end # delete
      
      def expire_all
        @_store = {}
        return nil
      end # expire_all
      
    end # LocalMemory
  end # Adapters
end # Cachetastic