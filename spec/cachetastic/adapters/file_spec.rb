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
      base.file_path('09677cd81f84c4f31d25450b5e8b1362ffa8775a').should == File.join(FileUtils.pwd, 'cachetastic', 'animal_cache', '978', 'e6d', '2ad', '1d2', '442', '03c', '569', '8ca', '9de', 'a3a', '584', 'cf9', '05b', '2', 'cache.txt')
    end
    
  end
  
end
