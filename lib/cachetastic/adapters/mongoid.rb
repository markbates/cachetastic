module Cachetastic
  module Adapters
    class Mongoid < Cachetastic::Adapters::Base

      class Store
        include ::Mongoid::Document
        include ::Mongoid::Timestamps

        field :cache_class, type: String
        field :key, type: String
        field :value, type: Object
        field :expiry_time, type: DateTime

        index({cache_class: 1, key: 1}, {background: true})

        validates :cache_class, presence: true
        validates :key, presence: true, uniqueness: {scope: :cache_class}
        validates :value, presence: {allow_blank: true}
        validates :expiry_time, presence: true
      end

      attr_accessor :klass

      def initialize(klass)
        self.klass = klass
        super
      end

      def get(key) # :nodoc:
        obj = connection.where(key: key).first
        if obj
          if obj.expiry_time > Time.now
            return obj.value
          else
            obj.destroy
          end
        end
        return nil
      end # get

      def set(key, value, expiry_time = configatron.cachetastic.defaults.default_expiry) # :nodoc:
        Cachetastic::Adapters::Mongoid::Store.create!(cache_class: self.klass.name, key: key, value: value, expiry_time: expiry_time.from_now)
        return value
      end # set

      def delete(key) # :nodoc:
        obj = connection.where(key: key).first
        if obj
          obj.destroy
        end
        return nil
      end # delete

      def expire_all # :nodoc:
        connection.destroy_all
        return nil
      end # expire_all

      def transform_key(key) # :nodoc:
        key.to_s.hexdigest
      end

      private
      def connection
        @connection ||= begin
          Cachetastic::Adapters::Mongoid::Store.create_indexes
          Cachetastic::Adapters::Mongoid::Store.where(cache_class: self.klass.name)
        end
      end

    end
  end
end