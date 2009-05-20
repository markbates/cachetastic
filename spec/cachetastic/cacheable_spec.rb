require File.dirname(__FILE__) + '/../spec_helper'

class MyObject
  include Cachetastic::Cacheable
end

module My
  module Namespaced
    class Thing
      include Cachetastic::Cacheable
    end
    class Animal
      include Cachetastic::Cacheable
    end
  end
end

describe Cachetastic::Cacheable do
  
  describe 'cache_class' do
    
    it 'should create a new cache class if one doesnt already exist' do
      Cachetastic::Cacheable.should_not be_const_defined(:MyObjectCache)
      MyObject.cache_class.should == Cachetastic::Cacheable::MyObjectCache
      Cachetastic::Cacheable.should be_const_defined(:MyObjectCache)
      Cachetastic::Cacheable::MyObjectCache.new.should be_kind_of(Cachetastic::Cache)
    end
    
    it 'should handle namespaced classes correctly' do
      Cachetastic::Cacheable.should_not be_const_defined(:My_Namespaced_ThingCache)
      My::Namespaced::Thing.cache_class.should == Cachetastic::Cacheable::My_Namespaced_ThingCache
      Cachetastic::Cacheable.should be_const_defined(:My_Namespaced_ThingCache)
      Cachetastic::Cacheable::My_Namespaced_ThingCache.new.should be_kind_of(Cachetastic::Cache)
    end
    
    it 'should override cache_klass to return the name of the original class, not the generated class' do
      My::Namespaced::Animal.cache_class.cache_klass.should == My::Namespaced::Animal
    end
    
  end
  
end
