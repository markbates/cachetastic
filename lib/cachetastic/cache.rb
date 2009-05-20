module Cachetastic
  class Cache
    
    class << self
      
      def get(key, &block)
        do_with_logging(:get, key) do
          val = self.adapter.get(key, &block)
          handle_store_object(key, adapter.unmarshal(val), &block)
        end
      end # get
      
      def set(key, value, expiry_time = nil)
        do_with_logging(:set, key) do
          self.adapter.set(key, value, expiry_time)
        end
      end # set
      
      def delete(key)
        do_with_logging(:delete, key) do
          self.adapter.delete(key)
        end
      end # delete
      
      def expire_all
        do_with_logging(:expire_all, nil) do
          self.adapter.expire_all
        end
      end # expire_all
      
      def adapter
        unless @_adapter && @_adapter.valid?
          @_adapter = Cachetastic::Adapters.build(cache_klass)
        end
        @_adapter
      end # adapter
      
      def clear_adapter!
        @_adapter = nil
      end
      
      def cache_klass
        self
      end
      
      def logger
        unless @_logger
          @_logger = Cachetastic::Logger.new(adapter.logger)
        end
        @_logger
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
        
        if val.respond_to?(:empty?)
          val = nil if val.empty?
        elsif val.respond_to?(:blank?)
          val = nil if val.blank?
        end
        return val unless val.nil?
        
        val = yield if block_given?
        return val
      end
      
      def do_with_logging(action, key)
        if adapter.debug?
          start_time = Time.now
          logger.debug(:starting, action, cache_klass.name, key)
          res = yield if block_given?
          end_time = Time.now
          str = ''
          unless res.nil?
            str = "[#{res.class.name}]"
            str << "\t[Size = #{res.size}]" if res.respond_to? :size
            str << "\t" << res.inspect
          end
          logger.debug(:finished, action, cache_klass.name, key, (end_time - start_time), str)
          return res
        else
          return yield if block_given?
        end
      end
      
    end # class << self
    
  end # Cache
end # Cachetastic