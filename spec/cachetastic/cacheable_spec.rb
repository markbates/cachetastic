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
  
  before(:each) do
    MyObject.cache_class.clear_adapter!
  end
  
  after(:each) do
  end
  
  describe 'cache_class' do
    
    it 'should create a new cache class if one doesnt already exist' do
      MyObject.cache_class.should == Cachetastic::Cacheable::MyObjectCache
      Cachetastic::Cacheable::MyObjectCache.instance.should be_kind_of(Cachetastic::Cache)
    end
    
    it 'should handle namespaced classes correctly' do
      Cachetastic::Cacheable.should_not be_const_defined(:My_Namespaced_ThingCache)
      My::Namespaced::Thing.cache_class.should == Cachetastic::Cacheable::My_Namespaced_ThingCache
      Cachetastic::Cacheable.should be_const_defined(:My_Namespaced_ThingCache)
      Cachetastic::Cacheable::My_Namespaced_ThingCache.instance.should be_kind_of(Cachetastic::Cache)
    end
    
    it 'should override cache_klass to return the name of the original class, not the generated class' do
      My::Namespaced::Animal.cache_class.cache_klass.should == My::Namespaced::Animal
    end
    
    it 'should use the original class name for looking up settings' do
      configatron.temp do
        configatron.cachetastic.my_object.adapter = Cachetastic::Adapters::Memcached
        MyObject.cache_class.adapter.should be_instance_of(Cachetastic::Adapters::Memcached)
      end
    end
    
  end
  
  describe 'cacher' do
    
    it 'should retreive from, or cache, from the cache based on the key at the instance level' do
      obj = My::Namespaced::Animal.new
      obj.instance_eval do
        def roar
          cacher('roar') do
            "roar!! #{rand}"
          end
        end
      end
      obj.roar.should match(/^roar!! (\d{1}\.{1}\d+)$/)
      val = obj.roar
      5.times do
        obj.roar.should == val
      end
      Cachetastic::Cacheable::My_Namespaced_AnimalCache.get('roar').should == val
    end
    
    it 'should retreive from, or cache, from the cache based on the key at the class level' do
      My::Namespaced::Thing.class_eval do
        def self.shout
          cacher('shout') do
            "shout!! #{rand}"
          end
        end
      end
      My::Namespaced::Thing.shout.should match(/^shout!! (\d{1}\.{1}\d+)$/)
      val = My::Namespaced::Thing.shout
      5.times do
        My::Namespaced::Thing.shout.should == val
      end
      Cachetastic::Cacheable::My_Namespaced_ThingCache.get('shout').should == val
    end
    
    it 'should return the object, not the memcached response' do
      configatron.temp do
        configatron.cachetastic.my_object.adapter = Cachetastic::Adapters::Memcached
        MyObject.class_eval do 
          def self.say_random
            cacher('say_random') do
              "Random!! #{rand}"
            end
          end
        end
        MyObject.cache_class.adapter.should be_instance_of(Cachetastic::Adapters::Memcached)
        r = MyObject.say_random
        r.should match(/^Random!! (\d{1}\.{1}\d+)$/)
        5.times do
          r.should == MyObject.say_random
        end
      end
    end
    
  end
  
  describe 'cache_self' do
    
    it 'should cache itself using the cachetastic_key method as the key' do
      MyObject.cache_class
      Cachetastic::Cacheable::MyObjectCache.get(1).should be_nil
      
      obj = MyObject.new
      obj.instance_eval do
        def cachetastic_key
          1
        end
        def value
          @value ||= rand
        end
      end
      
      obj.cache_self
      Cachetastic::Cacheable::MyObjectCache.get(1).should_not be_nil
      Cachetastic::Cacheable::MyObjectCache.get(1).value.should == obj.value
    end
    
  end
  
  describe 'uncache_self' do
    
    it 'should cache itself using the cachetastic_key method as the key' do
      MyObject.cache_class
      Cachetastic::Cacheable::MyObjectCache.get(2).should be_nil
      
      obj = MyObject.new
      obj.instance_eval do
        def cachetastic_key
          2
        end
      end
      
      obj.cache_self
      Cachetastic::Cacheable::MyObjectCache.get(2).should_not be_nil
      
      obj.uncache_self
      Cachetastic::Cacheable::MyObjectCache.get(2).should be_nil
    end
    
  end
  
end
