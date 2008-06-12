require 'singleton'
# When creating a new 'Cache' this class should be extended.
# Once extended you'll only need to override just the methods
# that are different for your cache.
#   class MyAwesomeCache < Cachetastic::Caches::Base
#   end
#   MyAwesomeCache.set(1, "One")
#   MyAwesomeCache.get(1) # => "One"
#   MyAwesomeCache.update(1, "One!!")
#   MyAwesomeCache.get(1) # => "One!!"
#   MyAwesomeCache.delete(1)
#   MyAwesomeCache.get(1) # => nil
# 
#   class MyAwesomeCache < Cachetastic::Caches::Base
#     class << self
#       def get(key)
#         super(key) do
#           set(key, key * 10)
#         end
#       end
#     end
#   end
#   MyAwesomeCache.set(1, "One")
#   MyAwesomeCache.get(1) # => "One"
#   MyAwesomeCache.delete(1)
#   MyAwesomeCache.get(1) # => 10
class Cachetastic::Caches::Base

  # Used to store a list of all the caches registered with the system.
  # In order for a cache to be registered it must extend Cachetastic::Caches::Base.
  class RegisteredCaches
    include Singleton
    
    # list of all caches registered with the system.
    attr_reader :list
    
    def initialize
      @list = []
    end
    
  end

  # everything is done at the class level. there won't be any 'instances of it'
  # using class << self means we don't have to prefix each method with 'self.'
  class << self
    
    # Returns a list of all registered caches in the system.
    def all_registered_caches
      RegisteredCaches.instance.list
    end
    
    # Returns an object from the cache for a given key.
    # If the object comes back as nil and a block is given
    # that block will be run and the results of the block
    # will be run. This can be used to JIT caches, just make
    # sure in the block to call the set method because the
    # results of the block are not automatically cached.
    def get(key, &block)
      res = nil
      do_with_logging(:get, key) do
        retryable(:on => ArgumentError) do
          begin
            res = adapter.get(key.to_s)
            if res.nil?
              res = yield key if block_given?
            else
              res = unmarshall(res)
            end
            res
          rescue ArgumentError => e
            m = e.message.match(/class\/module .*/)
            if m
              m = m.to_s
              m.gsub!("class/module", '')
              m.gsub!("(ArgumentError)", '')
              require m.strip.underscore
              raise e
            end
          rescue Exception => e
            raise e
          end
        end
      end
      res
    end
    
    # Set a particular object info the cache for the given key.
    # An optional third parameter sets the expiry time for the object in the cache.
    # The default for this expiry is set as either 0, meaning it never expires, or
    # if there's a default_expiry time set in the config file, that file will be
    # used.
    # If there is an expiry_swing set in the config file it will be +/- to the
    # expiry time. See also: calculate_expiry_time
    def set(key, value, expiry = adapter.configuration.retrieve(:default_expiry, 0))
      do_with_logging(:set, key) do
        expiry = calculate_expiry_time(expiry)
        adapter.set(key.to_s, marshall(value), expiry.to_i)
        logger.info('', '', :expiry, cache_name, key, expiry.to_i)
        value
      end
    end
    
    alias_method :put, :set
    
    # Deletes an object from the cache. The optional delay parameter
    # sets an offset, in seconds, for when the object should get deleted.
    # The default of 0 means the object gets deleted right away.
    def delete(key, delay = 0)
      do_with_logging(:delete, key) do
        adapter.delete(key.to_s, delay)
      end
    end
    
    # Expires all objects for this cache.
    def expire_all
      adapter.expire_all
      logger.info('', '', :expired, cache_name)
    end
    
    # Raises a MethodNotImplemented exception. This method should be overridden
    # in the child class to enable a populating the cache with all things that
    # should be in there. 
    needs_method :populate_all
    
    # A convenience method that returns statistics for the underlying Cachetastic::Adapters::Base for the cache.
    def stats
      adapter.stats
    end
    
    # Returns a 'methodize' version of the cache's class name. This gets used in logging,
    # namespacing, and as the key in the Cachetastic::Connection class.
    #   MyAwesomeCache.cache # => "my_awesome_cache"
    #   Cachetastic::Caches::Base # => "cachetastic_caches_base"
    def cache_name
      self.name.methodize
    end
    
    # Returns the underlying Cachetastic::Adapters::Base for this cache.
    def adapter
      a = cache_conn_instance.get(cache_name)
      if adapter_supported?(a.class)
        return a
      else
        raise Cachetastic::Errors::UnsupportedAdapter.new(cache_name, a.class)
      end
    end
    
    # Returns the Cachetastic::Logger for the underlying Cachetastic::Adapters::Base.
    def logger
      adapter.logger
    end
    
    # Returns an array of unsupported adapters for this cache. Defaults to an empty
    # array which will let any adapter be used by the cache. Override in your specific
    # cache to prevent certain adapters.
    def unsupported_adapters
      []
    end
    
    # Returns true/false on whether the adapter you want to use is supported for the cache.
    def adapter_supported?(a = cache_conn_instance.get(cache_name).class)
      return !unsupported_adapters.include?(a)
    end
    
    def marshall(value)
      return value if value.nil?
      return case adapter.configuration.retrieve(:marshall_method, :none).to_sym
      when :yaml
        YAML.dump(value)
      when :ruby
        Marshal.dump(value)
      else
        value
      end
    end
    
    def unmarshall(value)
      return value if value.nil?
      return case adapter.configuration.retrieve(:marshall_method, :none).to_sym
      when "yaml"
        YAML.load(value)
      when "ruby"
        Marshal.load(value)
      else
        value
      end
    end
    
    private
    # If the expiry time is set to 60 minutes and the expiry_swing time is set to
    # 15 minutes, this method will return a number between 45 minutes and 75 minutes.
    def calculate_expiry_time(expiry) # :doc:
      exp_swing = adapter.configuration.retrieve(:expiry_swing, 0)
      if exp_swing && exp_swing != 0
        swing = rand(exp_swing.to_i)
        case rand(2)
        when 0
          expiry = (expiry.to_i + swing)
        when 1
          expiry = (expiry.to_i - swing)
        end
      end
      expiry
    end
    
    def inherited(child)
      # puts "child: #{child.inspect}"
      all_registered_caches << child.to_s
      # puts "all_registered_caches: #{all_registered_caches.inspect}"
    end
    
    def cache_conn_instance
      Cachetastic::Connection.instance
    end
    
    def do_with_logging(action, key)
      start_time = Time.now
      logger.info(:starting, action, cache_name, key)
      res = yield if block_given?
      end_time = Time.now
      str = ""
      unless res.nil?
        str = "[#{res.class.name}]"
        str << "\t[Size = #{res.size}]" if res.respond_to? :size
        str << "\t" << res.inspect if adapter.debug?
      end
      logger.info(:finished, action, cache_name, key, (end_time - start_time), str)
      res
    end
    
    # make sure people can't instaniate this object!
    def new(*args)
      raise NoMethodError.new("You can not instaniate this class!")
    end
    
  end

end