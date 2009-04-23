module Cachetastic
  module Cache
    
    def self.included(base)
      base.extend(Cachetastic::Cache::ClassMethods)
    end
    
    module ClassMethods
      
      def get(key, &block)
        self.adapter.get(key, &block)
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
        unless @adapter
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
      
    end # ClassMethods
    
  end # Cache
end # Cachetastic