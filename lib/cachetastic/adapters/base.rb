module Cachetastic
  module Adapters
    class Base
      
      attr_accessor :klass
      
      def initialize(klass)
        self.klass = klass
        configatron.cachetastic.defaults.configatron_keys.each do |key|
          define_accessor(key)
          self.send("#{key}=", configatron.cachetastic.defaults.send(key))
        end
        klass.to_configatron(:cachetastic).configatron_keys.each do |key|
          define_accessor(key)
          self.send("#{key}=", klass.to_configatron(:cachetastic).send(key))
        end
      end
      
      # Allows an adapter to transform the key
      # to a safe representation for it's backend.
      # For example, the key: '$*...123()%~q' is not a 
      # key for the file system, so the 
      # Cachetastic::Adapters::File class should override
      # this to make it safe for the file system.
      def transform_key(key)
        key
      end
      
      def valid?
        true
      end
      
      def marshal(value)
        case self.marshal_method.to_sym
        when :yaml
          return YAML.dump(value)
        when :ruby
          return Marshal.dump(value)
        else
          return value
        end
      end
      
      def unmarshal(value)
        case self.marshal_method.to_sym
        when :yaml
          return YAML.load(value)
        when :ruby
          return Marshal.load(value)
        else
          return value
        end
      end
      
      private
      # If the expiry time is set to 60 minutes and the expiry_swing time is set to
      # 15 minutes, this method will return a number between 45 minutes and 75 minutes.
      def calculate_expiry_time(expiry_time) # :doc:
        expiry_time = self.default_expiry if expiry_time.nil?
        exp_swing = self.expiry_swing
        if exp_swing && exp_swing != 0
          swing = rand(exp_swing.to_i)
          case rand(2)
          when 0
            expiry_time = (expiry_time.to_i + swing)
          when 1
            expiry_time = (expiry_time.to_i - swing)
          end
        end
        expiry_time
      end
      
      def define_accessor(key)
        eval(%{
          def #{key}
            @#{key}
          end
          def #{key}=(x)
            @#{key} = x
          end
        })        
      end
      
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
      
    end # Base
  end # Adapters
end # Cachetastic