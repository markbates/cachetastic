require 'configatron'
require 'logger'
require 'activesupport'
require 'fileutils'
require 'memcache'

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