require 'configatron'
require 'logger'
require 'active_support/core_ext'
require 'fileutils'
require 'singleton'
require 'uri'
begin
  require 'memcache'
rescue Exception => e
  puts "Memcached support is unavailable. To use Memcached do `gem install memcache-client`"
end
begin
  require 'dalli'
rescue Exception => e
  puts "Memcached (via Dalli) support is unavailable. To use Memcached (via Dalli) do `gem install dalli`"
end
begin
  require 'redis'
rescue Exception => e
  puts "Redis support is unavailable. To use Redis do `gem install redis`"
end

Dir.glob(File.join(File.dirname(__FILE__), 'cachetastic', '**/*.rb')).sort.each do |f|
  require File.expand_path(f)
end

configatron.cachetastic.defaults.set_default(:marshal_method, :none)
configatron.cachetastic.defaults.set_default(:expiry_swing, 0)
configatron.cachetastic.defaults.set_default(:default_expiry, 86400)
configatron.cachetastic.defaults.set_default(:debug, true)
configatron.cachetastic.defaults.set_default(:adapter, Cachetastic::Adapters::LocalMemory)
log_path = File.join(FileUtils.pwd, 'log', 'cachetastic.log')
FileUtils.mkdir_p(File.dirname(log_path))
logger = ::Logger.new(log_path)
logger.level = ::Logger::DEBUG
configatron.cachetastic.defaults.set_default(:logger, logger)