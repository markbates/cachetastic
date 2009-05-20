module Cachetastic
  module Adapters
    class Memcached < Cachetastic::Adapters::Base
      
      def initialize(klass)
        # puts "initialize: #{klass}"
        define_accessor(:servers)
        define_accessor(:mc_options)
        define_accessor(:delete_delay)
        self.delete_delay = 0
        self.servers = ['127.0.0.1:11211']
        self.mc_options = {:c_threshold => 10_000,
                           :compression => true,
                           :debug => false,
                           :readonly => false,
                           :urlencode => false}
        super
        connection
      end
      
      def get(key, &block)
        connection.get(transform_key(key), false)
      end # get
      
      def set(key, value, expiry_time = 0)
        connection.set(transform_key(key), marshal(value), calculate_expiry_time(expiry_time), false)
      end # set
      
      def delete(key)
        connection.delete(transform_key(key), self.delete_delay)
      end # delete
      
      def expire_all
        increment_version
        @_mc_connection = nil
        return nil
      end # expire_all
      
      def transform_key(key)
        key.to_s.hexdigest
      end
      
      def valid?
        return false if @_mc_connection.nil?
        return false unless @_mc_connection.active?
        return true
      end
      
      private
      def connection
        unless @_mc_connection && valid? && @_ns_version == get_version
          @_mc_connection = MemCache.new(self.servers, self.mc_options.merge(:namespace => namespace))
        end
        @_mc_connection
      end
      
      def ns_connection
        unless @_ns_connection
          @_ns_connection = MemCache.new(self.servers, self.mc_options.merge(:namespace => :namespace_versions))
        end
        @_ns_connection
      end
      
      def increment_version
        name = self.klass.name
        v = get_version
        ns_connection.set(name, v + 1)
      end

      def get_version
        name = self.klass.name
        v = ns_connection.get(name)
        if v.nil?
          ns_connection.set(name, 1)
          v = 1
        end
        v
      end
      
      def namespace
        @_ns_version = get_version
        "#{self.klass.name}.#{@_ns_version}"
      end
      
    end # Memcached
  end # Adapters
end # Cachetastic

#      c_threshold: 10_000
#      compression: true
#      debug: false
#      readonly: false
#      urlencode: false