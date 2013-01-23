module Cachetastic # :nodoc:
  # When creating a new 'Cache' this class should be extended.
  # Once extended you'll only need to override just the methods
  # that are different for your cache.
  #   class MyAwesomeCache < Cachetastic::Cache
  #   end
  # 
  #   MyAwesomeCache.set(1, "One")
  #   MyAwesomeCache.get(1) # => "One"
  #   MyAwesomeCache.update(1, "One!!")
  #   MyAwesomeCache.get(1) # => "One!!"
  #   MyAwesomeCache.delete(1)
  #   MyAwesomeCache.get(1) # => nil
  # 
  #   class MyAwesomeCache < Cachetastic::Cache
  #     def get(key)
  #       super(key) do
  #         set(key, key * 10)
  #       end
  #     end
  #   end
  # 
  #   MyAwesomeCache.set(1, "One")
  #   MyAwesomeCache.get(1) # => "One"
  #   MyAwesomeCache.delete(1)
  #   MyAwesomeCache.get(1) # => 10
  class Cache
    include Singleton
    
    # everything is done at the class level. there won't be any 'instances of it'
    # using class << self means we don't have to prefix each method with 'self.'
    class << self

      def method_missing(sym, *args, &block)
        self.instance.send(sym, *args, &block)
      end

      def available_caches
        @available_caches ||= []
      end

      def inherited(klass)
        available_caches << klass
        super
      end

    end # class << self

    # Returns an object from the cache for a given key.
    # If the object comes back as nil and a block is given
    # that block will be run and the results of the block
    # will be returned. This can be used to JIT caches, just make
    # sure in the block to call the set method because the
    # results of the block are not automatically cached.
    def get(key, &block)
      do_with_logging(:get, key) do
        retryable do
          val = self.adapter.get(key)
          handle_store_object(key, adapter.unmarshal(val), &block)
        end
      end
    end # get

    # Set a particular object info the cache for the given key.
    #
    # An optional third parameter sets the expiry time for the object in the cache.
    # If no expiry_time is passed in then the default expiry_time that has been configured
    # will be used.
    #
    # If there is an the expiry_swing setting is configured it will be +/- to the
    # expiry time.
    def set(key, value, expiry_time = nil)
      do_with_logging(:set, key) do
        retryable do
          self.adapter.set(key, adapter.marshal(value), calculate_expiry_time(expiry_time))
        end
      end
    end # set

    # Deletes an object from the cache.
    def delete(key)
      do_with_logging(:delete, key) do
        retryable do
          self.adapter.delete(key)
          nil
        end
      end
    end # delete

    # Expires all objects for this cache.
    def expire_all
      do_with_logging(:expire_all, nil) do
        retryable do
          self.adapter.expire_all
          nil
        end
      end
    end # expire_all

    # Returns the underlying Cachetastic::Adapters::Base for this cache.
    def adapter
      unless @_adapter && @_adapter.valid?
        @_adapter = Cachetastic::Adapters.build(cache_klass)
      end
      @_adapter
    end # adapter

    # Clears the adapter so it can be redefined. This is useful if you have
    # reconfigured the cache to use a different adapater, or different settings.
    def clear_adapter!
      @_adapter = nil
    end

    def cache_klass # :nodoc:
      self.class
    end

    # Returns the Cachetastic::Logger for this cache.
    def logger
      unless @_logger
        @_logger = Cachetastic::Logger.new(adapter.logger)
      end
      @_logger
    end

    def to_configatron(*args) # :nodoc:
      self.class.to_configatron(*args)
    end

    private
    # If the expiry time is set to 60 minutes and the expiry_swing time is set to
    # 15 minutes, this method will return a number between 45 minutes and 75 minutes.
    def calculate_expiry_time(expiry_time) # :doc:
      expiry_time = self.adapter.default_expiry if expiry_time.nil?
      exp_swing = self.adapter.expiry_swing
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
      
      val = yield key if block_given?
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
          res = adapter.unmarshal(res)
          str = "[#{res.class.name}]"
          str << "\t[Size = #{res.size}]" if res.respond_to? :size
          str << "\t" << res.inspect
        end
        logger.debug(:finished, action, cache_klass.name, key, (end_time - start_time), str)
        return res
      else
        return yield(key) if block_given?
      end
    end

    def retryable(options = {}, &block)
      opts = { tries: 3, on: Exception }.merge(options)

      retries = opts[:tries]
      retry_exceptions = [opts[:on]].flatten

      x = %{
        begin
          return yield
        rescue #{retry_exceptions.join(", ")} => e
          retries -= 1
          if retries > 0
            clear_adapter!
            retry
          else
            raise e
          end
        end
      }

      eval(x, &block)
    end
    
  end # Cache
end # Cachetastic