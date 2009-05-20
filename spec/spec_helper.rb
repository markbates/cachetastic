require 'rubygems'
require 'spec'

require File.join(File.dirname(__FILE__), '..', 'lib', 'cachetastic')

Spec::Runner.configure do |config|
  
  config.before(:all) do
    
  end
  
  config.after(:all) do
    
  end
  
  config.before(:each) do
    
  end
  
  config.after(:each) do
    
  end
  
end

class Cachetastic::BlockError < StandardError
end