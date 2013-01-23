module Cachetastic
  module Adapters
    class Redis < Cachetastic::Adapters::Base

      def initialize(klass)
        define_accessor(:redis_host)
        define_accessor(:redis_options)
        define_accessor(:delete_delay)
        super
        self.redis_host ||= "redis://localhost:6379/"
        parsed_url = URI.parse(self.redis_host)
        self.redis_options = ::Redis::Client::DEFAULTS.merge({
          db: "cachetastic",
          url: self.redis_host,
          scheme: parsed_url.scheme,
          host: parsed_url.host,
          port: parsed_url.port,
          password: parsed_url.password
        })
        self.marshal_method = :yaml if self.marshal_method == :none
        connection
      end

      def get(key) # :nodoc:
        connection.get(transform_key(key))
      end # get

      def set(key, value, expiry_time = configatron.cachetastic.defaults.default_expiry) # :nodoc:
        connection.setex(transform_key(key), expiry_time, value)
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