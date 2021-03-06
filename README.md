# What is Cachetastic?

Cachetastic is an incredibly easy to use and administer caching framework. Just because it is easy to use, does not mean that it is light with features. Cachetastic allows you to create classes that extend <code>Cachetastic::Cache</code>, configure them each individually, and much more.

Unlike other systems each cache in your system can use different backends via the use of adapters that get assigned to each cache, and globally. You can define different expiration times, loggers, marshal methods, and more! And again, you can choose to define these settings globally, or for each cache!

Adapters are easy to write, so if the built in adapters don't float your boat, you can easily knock one off in short order.

## Configuration:

Configuration of Cachetastic is done using the Configatron gem.

All configuration settings hang off of the <code>cachetastic</code> namespace on <code>configatron</code>. The default settings all hang off the <code>defaults</code> namespace on the <code>cachetastic</code> namespace, as shown below:

```ruby
# This will write detailed information to the logger.
configatron.cachetastic.defaults.debug = false

# This is the type of file store to be used for this cache.
# More adapters can be developed and plugged in as desired.
# The default is Cachetastic::Adapters::LocalMemory
configatron.cachetastic.defaults.adapter = Cachetastic::Adapters::LocalMemory
configatron.cachetastic.defaults.adapter = Cachetastic::Adapters::File
configatron.cachetastic.defaults.adapter = Cachetastic::Adapters::Memcached
configatron.cachetastic.defaults.adapter = Cachetastic::Adapters::Redis

# This will marshall objects into and out of the store.
# The default is :none, except for Cachetastic::Adapters::File and Cachetastic::Adapters::Redis, which default to :yaml
configatron.cachetastic.defaults.marshall_method = :none
configatron.cachetastic.defaults.marshall_method = :yaml
configatron.cachetastic.defaults.marshall_method = :ruby

# This sets how long objects will live in the cache before they are auto expired.
configatron.cachetastic.defaults.default_expiry = 86400 # time in seconds (default: 24 hours)

# When saving objects into the cache the expiry_swing is +/- to the expiry time.
# Example: if the expiry time is 1 minute, and the swing is 15 seconds,
# objects will go into the cache with an expiry time sometime between 45 seconds and 75 seconds.
# The default is 0 seconds.
configatron.cachetastic.defaults.expiry_swing = 15

# Configure logging for the system.
# n number of logs can be configured for a cache.
log_1 = Logger.new(STDOUT)
log_1.level = Logger::DEBUG
log_2 = Logger.new("log/cachetastic.log")
log_2.level = Logger::ERROR
configatron.cachetastic.defaults.logger = [log_1, log_2]
```

Overriding settings per cache is very simple. Let's take the following two caches:

```ruby
class UserCache < Cachetastic::Cache
end

class Admin::UserCache < Cachetastic::Cache
end
```

If we wanted to set the <code>UserCache</code> to use the <code>Cachetastic::Adapters::File</code> adapter and we wanted to set the adapter for 
the <code>Admin::UserCache</code> to use <code>Cachetastic::Adapters::Memcached</code>, we would configure them like such:

```ruby
configatron.cachetastic.user_cache.adapter = Cachetastic::Adapters::File
configatron.cachetastic.admin.user_cache.adapter = Cachetastic::Adapters::Memcached
```

In this scenario we have changed the adapters for each of the classes. All of the other default settings will remain intact for each of those classes. This makes it incredibly easy to just change the one parameter you need, and not have to reset them all.
    
## Examples:

```ruby
class MyAwesomeCache < Cachetastic::Cache
end

MyAwesomeCache.set(1, [1,2,3])
MyAwesomeCache.get(1) # => [1,2,3]

class MyAwesomeCache < Cachetastic::Cache
  class << self
    def get(key, x, y)
      super(key) do
        n = x + y
        set(key, n)
        n
      end
    end
  end
end

MyAwesomeCache.get(1, 2, 4) # => 8
MyAwesomeCache.get(1, 4, 4) # => 8
```