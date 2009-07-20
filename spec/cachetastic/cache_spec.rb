require File.dirname(__FILE__) + '/../spec_helper'

class SimpleCache < Cachetastic::Cache
end

describe Cachetastic::Cache do
  
  before(:each) do
    configatron.cachetastic.defaults.adapter = Cachetastic::Adapters::LocalMemory
  end
  
  describe 'get' do
    
    it 'should execute a block if the result is nil' do
      val = SimpleCache.get(:mark)
      val.should be_nil
      
      val = SimpleCache.get(:mark) do |key|
        SimpleCache.set(:mark, "Hello #{key}")
      end
      val.should_not be_nil
      val.should == 'Hello mark'
      
      val = SimpleCache.get(:mark)
      val.should_not be_nil
      val.should == 'Hello mark'
    end
    
  end
  
  describe 'adapter' do
    
    it 'should return the adapter for the cache' do
      SimpleCache.clear_adapter!
      SimpleCache.adapter.should_not be_nil
      SimpleCache.adapter.should be_kind_of(Cachetastic::Adapters::LocalMemory)
      configatron.temp do
        SimpleCache.clear_adapter!
        configatron.cachetastic.defaults.adapter = Cachetastic::Adapters::File
        SimpleCache.adapter.should be_kind_of(Cachetastic::Adapters::File)
      end
    end
    
    it 'should retain the adapter for the life of the class' do
      adapter = SimpleCache.adapter
      adapter.should_not be_nil
      3.times do
        adapter.should === SimpleCache.adapter
      end
    end
    
  end
  
  describe 'cache_klass' do
    
    it 'should return the class constant by default' do
      SimpleCache.cache_klass.should == SimpleCache
    end
    
  end
  
  describe 'calculate_expiry_time' do
    
    it 'should properly +/- swing to the expiry time' do
      configatron.temp do
        configatron.cachetastic.defaults.expiry_swing = 15
        configatron.cachetastic.defaults.default_expiry = 60
        SimpleCache.class_eval do
          class << self
            public :calculate_expiry_time
          end
        end
        10.times do
          SimpleCache.calculate_expiry_time(60).should >= 45
          SimpleCache.calculate_expiry_time(60).should <= 75
        end
      end
    end
    
  end
  
  
  describe 'logging' do
    
    before(:each) do
      Time.stub!(:now).and_return(Time.at(0))
      @logger = mock(Logger.new(STDOUT))
      configatron.cachetastic.simple_cache.debug = true
    end
    
    describe 'get' do
      
      it 'should log a get call' do
        SimpleCache.logger.stub!(:debug)
        SimpleCache.logger.should_receive(:debug).with(:starting, :get, 'SimpleCache', 1)
        SimpleCache.logger.should_receive(:debug).with(:finished, :get, 'SimpleCache', 1, 0.0, '')
        SimpleCache.get(1)
      end
      
    end
    
    describe 'set' do

      it 'should log a set call' do
        SimpleCache.logger.stub!(:debug)
        SimpleCache.logger.should_receive(:debug).with(:starting, :set, 'SimpleCache', 1)
        SimpleCache.logger.should_receive(:debug).with(:finished, :set, 'SimpleCache', 1, 0.0, "[String]\t[Size = 3]\t\"foo\"")
        SimpleCache.set(1, 'foo')
      end

    end
    
    describe 'delete' do
      
      it 'should log a delete call' do
        SimpleCache.logger.stub!(:debug)
        SimpleCache.logger.should_receive(:debug).with(:starting, :delete, 'SimpleCache', 1)
        SimpleCache.logger.should_receive(:debug).with(:finished, :delete, 'SimpleCache', 1, 0.0, '')
        SimpleCache.delete(1)
      end
      
    end
    
    describe 'expire_all' do
      
      it 'should log an expire_all' do
        SimpleCache.logger.stub!(:debug)
        SimpleCache.logger.should_receive(:debug).with(:starting, :expire_all, 'SimpleCache', nil)
        SimpleCache.logger.should_receive(:debug).with(:finished, :expire_all, 'SimpleCache', nil, 0.0, '')
        SimpleCache.expire_all
      end
      
    end
    
  end
  
end
