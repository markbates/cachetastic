require File.dirname(__FILE__) + '/../spec_helper'

class SimpleCache < Cachetastic::Cache
end

describe Cachetastic::Cache do
  
  before(:each) do
    configatron.cachetastic.defaults.adapter = Cachetastic::Adapters::LocalMemory
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
  
end
