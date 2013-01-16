require File.dirname(__FILE__) + '/../spec_helper'

describe Cachetastic::Cache::StoreObject do
  
  describe 'expired?' do
    
    it 'should return true if the object is expired' do
      obj = Cachetastic::Cache::StoreObject.new(nil, nil, 1.minute.ago)
      obj.should be_expired
    end
    
    it 'should return false if the object is not expired' do
      obj = Cachetastic::Cache::StoreObject.new(nil, nil, 1.minute.from_now)
      obj.should_not be_expired
    end
    
  end
  
end
