ENV["RACK_ENV"] ||= "test"

require 'bundler/setup'

require 'cachetastic' # and any other gems you need

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