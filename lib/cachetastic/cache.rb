module Cachetastic
  class Cache
    
    class << self
      
      def get(key, &block)
        val = self.adapter.get(key, &block)
        handle_store_object(key, adapter.unmarshal(val), &block)
      end # get
      
      def set(key, value, expiry_time = nil)
        self.adapter.set(key, value, expiry_time)
      end # set
      
      def delete(key)
        self.adapter.delete(key)
      end # delete
      
      def expire_all
        self.adapter.expire_all
      end # expire_all
      
      def adapter
        unless @adapter && @adapter.valid?
          adp = self.to_configatron(:cachetastic).adapter
          if adp.nil?
            adp = configatron.cachetastic.defaults.adapter
          end
          @adapter = adp.new(self)
        end
        @adapter
      end # adapter
      
      def clear_adapter!
        @adapter = nil
      end
      
      private
      def handle_store_object(key, val, &block)
        if val.is_a?(Cachetastic::Cache::StoreObject)
          if val.expired?
            self.delete(key)
            val = nil
          else
            val = val.value
          end
        end

        case val
        when Array, Hash
          val = nil if val.empty?
        when String
          val = nil if val.blank?
        end
        return val unless val.nil?
        
        val = yield if block_given?
        return val
      end
      
    end # class << self
    
  end # Cache
end # Cachetastic