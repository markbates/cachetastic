require 'configatron'
require 'logger'
require 'activesupport'
require 'fileutils'
require 'memcache'

Dir.glob(File.join(File.dirname(__FILE__), 'cachetastic', '**/*.rb')).each do |f|
  require File.expand_path(f)
end

configatron.cachetastic.defaults.set_default(:marshal_method, :none)
configatron.cachetastic.defaults.set_default(:expiry_swing, 0)
configatron.cachetastic.defaults.set_default(:default_expiry, 86400)
configatron.cachetastic.defaults.set_default(:debug, false)
configatron.cachetastic.defaults.set_default(:adapter, Cachetastic::Adapters::LocalMemory)
configatron.cachetastic.defaults.set_default(:logger, ::Logger.new(STDOUT))