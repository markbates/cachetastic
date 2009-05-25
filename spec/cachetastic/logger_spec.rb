require File.dirname(__FILE__) + '/../spec_helper'

describe Cachetastic::Logger do
  
  before(:each) do
    Time.stub!(:now).and_return(Time.at(0))
    @logger = mock(Logger.new(STDOUT))    
  end
  
  [:fatal, :error, :warn, :info, :debug].each do |meth|
    
    describe meth do
      
      it "should call the underlying #{meth} method" do
        @logger.should_receive(meth).with("[CACHE] [#{meth.to_s.upcase}]\t12/31/69 19:00:00\tHi!")
        
        c_logger = Cachetastic::Logger.new(@logger)
        c_logger.send(meth, 'Hi!')
      end
      
    end
    
  end
  
end
