module Cachetastic # :nodoc:
  module Adapters
    class Dalli < Cachetastic::Adapters::Base

      def initialize(klass) # :nodoc:
        define_accessor(:dalli_servers)
        define_accessor(:dalli_options)
        define_accessor(:dalli_username)
        define_accessor(:dalli_password)
        self.dalli_servers = ['127.0.0.1:11211']
        self.dalli_options = {}
        super
        connection
      end

      def get(key) # :nodoc:
        connection.get(transform_key(key), false)
      end # get

      def set(key, value, expiry_time = configatron.cachetastic.defaults.default_expiry) # :nodoc:
        connection.set(transform_key(key), marshal(value), expiry_time, false)
      end # set

      def delete(key) # :nodoc:
        connection.delete(transform_key(key))
      end # delete

      def expire_all # :nodoc:
        increment_version
        @_mc_connection = nil
        return nil
      end # expire_all

      def transform_key(key) # :nodoc:
        key.to_s.hexdigest
      end

      # Return <tt>false</tt> if the connection to Memcached is
      # either <tt>nil</tt> or not active.
      def valid?
        return false if @_mc_connection.nil?
        return false unless @_mc_connection.stats
        return true
      end

      private
      def connection
        unless @_mc_connection && valid? && @_ns_version == get_version
          @_mc_connection = ::Dalli::Client.new(self.dalli_servers, self.dalli_options.merge(namespace: namespace))
        end
        @_mc_connection
      end

      def ns_connection
        if !@_ns_connection || !@_ns_connection.stats
          @_ns_connection = ::Dalli::Client.new(self.dalli_servers, self.dalli_options.merge(namespace: :namespace_versions))
        end
        @_ns_connection
      end

      def increment_version
        name = self.klass.name
        v = get_version
        ns_connection.set(name, v + Time.now.to_i)
      end

      def get_version
        name = self.klass.name
        v = ns_connection.get(name)
        if v.nil?
          v = Time.now.to_i
          ns_connection.set(name, v)
        end
        v.to_i
      end

      def namespace
        @_ns_version = get_version
        "#{self.klass.name}.#{@_ns_version}"
      end

    end
  end
end