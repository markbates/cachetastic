require File.dirname(__FILE__) + '/../../spec_helper'

class AnimalCache
  include Cachetastic::Cache
end

describe Cachetastic::Adapters::File do
  
  describe 'transform_key' do
    
    it 'should make the key file system safe' do
      base = Cachetastic::Adapters::File.new(AnimalCache)
      base.transform_key('$*...123()%~q').should == '09677cd81f84c4f31d25450b5e8b1362ffa8775a'
    end
    
  end
  
  describe 'file_path' do
    
    it 'should return a proper file path for the key' do
      base = Cachetastic::Adapters::File.new(AnimalCache)
      base.file_path('09677cd81f84c4f31d25450b5e8b1362ffa8775a').should == File.join(FileUtils.pwd, 'cachetastic', 'animal_cache', '978e', '6d2a', 'd1d2', '4420', '3c56', '98ca', '9dea', '3a58', '4cf9', '05b2', 'cache.data')
    end
    
  end
  
  describe 'expire_all' do
    
    it 'should delete the directory and all sub directories when called' do
      configatron.temp do
        configatron.cachetastic.defaults.adapter = Cachetastic::Adapters::File
        base_path = File.join(AnimalCache.adapter.storage_path, 'animal_cache')
        FileUtils.rm_rf(base_path)
        File.should_not be_exist(base_path)
        AnimalCache.set('bear', 'Grizzly Bear!')
        AnimalCache.get('bear').should == 'Grizzly Bear!'
        File.should be_exist(base_path)
        File.should be_exist(AnimalCache.adapter.file_path('bear'))
        AnimalCache.expire_all
        File.should_not be_exist(base_path)
        File.should_not be_exist(AnimalCache.adapter.file_path(AnimalCache.adapter.transform_key('bear')))
      end
    end
    
  end
  
end
