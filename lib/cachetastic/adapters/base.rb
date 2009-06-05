module Cachetastic
  module Adapters
    
    class << self
      
      def build(klass)
        adp = klass.to_configatron(:cachetastic).adapter
        if adp.nil?
          adp = configatron.cachetastic.defaults.adapter
        end
        adp.new(klass)
      end
      
    end # class << self
    
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
      
      def debug?
        return self.debug if self.respond_to?(:debug)
        return false
      end
      
      def marshal(value)
        return nil if value.nil?
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
        return nil if value.nil?
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
      def define_accessor(key)
        instance_eval(%{
          def #{key}
            @#{key}
          end
          def #{key}=(x)
            @#{key} = x
          end
        })        
      end
      
    end # Base
  end # Adapters
end # Cachetastic