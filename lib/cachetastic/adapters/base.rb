module Cachetastic # :nodoc:
  module Adapters
    
    class << self
      
      # This method will return the appropriate 
      # <tt>Cachetastic::Adapters::Base</tt> class that is defined
      # for the Class passed in. If an adapter has not been
      # defined for the Class than the default adapter is returned.
      # 
      # Examples:
      #   configatron.cachetastic.defaults.adapter = Cachetastic::Adapters::LocalMemory
      #   configatron.cachetastic.user.adapter = Cachetastic::Adapters::Memcached
      #   Cachetastic::Adapters.build(User).class # => Cachetastic::Adapters::Memcached
      #   Cachetastic::Adapters.build(Comment).class # => Cachetastic::Adapters::LocalMemory
      def build(klass)
        adp = klass.to_configatron(:cachetastic).adapter
        if adp.nil?
          adp = configatron.cachetastic.defaults.adapter
        end
        adp.new(klass)
      end
      
    end # class << self
    
    # This class should be extended to create new adapters for various
    # backends. It is important that all subclasses call the <tt>initialize</tt>
    # method in this base, otherwise things just will not work right.
    # 
    # This base class provides common functionality and an API for all
    # adapters to be used with Cachetastic.
    # 
    # The default settings for all adapters are:
    # 
    #   configatron.cachetastic.defaults.marshal_method = :none
    #   configatron.cachetastic.defaults.expiry_swing = 0
    #   configatron.cachetastic.defaults.default_expiry = 86400
    #   configatron.cachetastic.defaults.debug = true
    #   configatron.cachetastic.defaults.adapter = Cachetastic::Adapters::LocalMemory
    #   logger = ::Logger.new(File.join(FileUtils.pwd, 'log', 'cachetastic.log'))
    #   logger.level = ::Logger::DEBUG
    #   configatron.cachetastic.defaults.logger = logger
    # 
    # See the README for more information on what each of those settings mean,
    # and what are values may be used for each one.
    class Base
      
      # The Class that this adapter is associated with. Note that it is a
      # <i>class</i> reference and not an instance reference.
      attr_accessor :klass
      
      # Creates a new adapter. It takes a class reference to tie the
      # instance of the adapter to a particular class. Note that it is a
      # <i>class</i> reference and not an instance reference.
      # 
      # Examples:
      #   Cachetastic::Adapters::Base.new(User)
      # 
      # Adapters are configured using the Configatron gem.
      # 
      # Examples:
      #   configatron.cachetastic.user.adapter = Cachetastic::Adapters::File
      #   configatron.cachetastic.user.expiry_time = 5.hours
      #   configatron.cachetastic.defaults.expiry_time = 24.hours
      # 
      # Refered to each adapter for its specific configuration settings.
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
      
      # <b>This method MUST be implemented by a subclass!</b>
      # 
      # The implementation of this method should take a key and return
      # an associated object, if available, from the underlying persistence
      # layer. 
      def get(key)
        raise NoMethodError.new('get')
      end # get
      
      # <b>This method MUST be implemented by a subclass!</b>
      # 
      # The implementation of this method should take a key, a value, and
      # an expiry time and save it to the persistence store, where it should
      # live until it is either deleted by the user of the expiry time has passed.
      def set(key, value, expiry_time = configatron.cachetastic.defaults.default_expiry)
        raise NoMethodError.new('set')
      end # set
      
      # <b>This method MUST be implemented by a subclass!</b>
      # 
      # The implementation of this method should take a key and remove
      # an object, if it exists, from an underlying persistence store.
      def delete(key)
        raise NoMethodError.new('delete')
      end # delete
      
      # <b>This method MUST be implemented by a subclass!</b>
      # 
      # The implementation of this method is expected to delete all
      # objects belonging to the associated cache from the underlying
      # persistence store. It is <b>NOT</b> meant to delete <b>ALL</b>
      # objects across <b>ALL</b> caches for the underlying persistence
      # store. That would be very very bad!!
      def expire_all
        raise NoMethodError.new('expire_all')
      end # expire_all
      
      # Allows an adapter to transform the key
      # to a safe representation for it's backend.
      # For example, the key: '$*...123()%~q' is not a 
      # key for the file system, so the 
      # Cachetastic::Adapters::File class should override
      # this to make it safe for the file system.
      def transform_key(key)
        key
      end
      
      # <b>This method MUST be implemented by a subclass!</b>
      # 
      # The implementation of this method should return <tt>true</tt>
      # if the adapter is in a valid state, and <tt>false</tt> if it is
      # not.
      def valid?
        true
      end
      
      def debug? # :nodoc:
        return self.debug if self.respond_to?(:debug)
        return false
      end
      
      def marshal(value) # :nodoc:
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
      
      def unmarshal(value) # :nodoc:
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