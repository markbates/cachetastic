module Cachetastic
  module Adapters
    class Redis < Cachetastic::Adapters::Base

      def initialize(klass)
        define_accessor(:redis_host)
        define_accessor(:redis_options)
        define_accessor(:delete_delay)
        self.redis_host ||= "redis://localhost:6379/"
        self.redis_options = ::Redis::Client::DEFAULTS.merge({
          db: "cachetastic",
          url: self.redis_host
        })
        super(klass)
        self.marshal_method = :yaml if self.marshal_method == :none
        connection
      end

      def get(key) # :nodoc:
        connection.get(transform_key(key))
      end # get

      def set(key, value, expiry_time = configatron.cachetastic.defaults.default_expiry) # :nodoc:
        so = Cachetastic::Cache::StoreObject.new(key, value, expiry_time.from_now)
        connection.set(transform_key(key), marshal(so))
        return value
      end # set

      def delete(key) # :nodoc:
        connection.del(transform_key(key))
      end # delete

      def expire_all # :nodoc:
        connection.flushdb
        return nil
      end # expire_all

      def transform_key(key) # :nodoc:
        key.to_s.hexdigest
      end

      def valid?
        !connection.nil?
      end

      private
      def connection
        if @connection.nil?
         @connection = ::Redis.new(self.redis_options)
        end
        return @connection
      end

    end
  end
end